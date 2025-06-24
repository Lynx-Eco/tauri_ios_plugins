import Tauri
import WebKit
import CoreLocation
import MapKit

struct PermissionRequest: Decodable {
    let accuracy: String?
    let background: Bool
}

struct LocationOptions: Decodable {
    let accuracy: String?
    let distanceFilter: Double?
    let timeout: Int?
    let maximumAge: Int?
    let enableHighAccuracy: Bool
    let showBackgroundLocationIndicator: Bool
}

struct RegionData: Decodable {
    let identifier: String
    let center: CoordinatesData
    let radius: Double
    let notifyOnEntry: Bool
    let notifyOnExit: Bool
}

struct CoordinatesData: Decodable {
    let latitude: Double
    let longitude: Double
}

struct DistanceRequest: Decodable {
    let from: CoordinatesData
    let to: CoordinatesData
}

class LocationPlugin: Plugin {
    private let locationManager = CLLocationManager()
    private var pendingLocationRequest: Invoke?
    private var locationUpdateTimer: Timer?
    private var locationOptions: LocationOptions?
    private var lastLocation: CLLocation?
    private var monitoredRegions: [String: CLCircularRegion] = [:]
    private let geocoder = CLGeocoder()
    
    @objc public override func load(webview: WKWebView) {
        super.load(webview: webview)
        locationManager.delegate = self
    }
    
    @objc public func checkPermissions(_ invoke: Invoke) throws {
        let authStatus = locationManager.authorizationStatus
        let whenInUse = authorizationStatusToString(authStatus, for: .whenInUse)
        let always = authorizationStatusToString(authStatus, for: .always)
        
        invoke.resolve([
            "whenInUse": whenInUse,
            "always": always
        ])
    }
    
    @objc public func requestPermissions(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(PermissionRequest.self)
        
        // Set desired accuracy
        if let accuracy = args.accuracy {
            locationManager.desiredAccuracy = parseAccuracy(accuracy)
        }
        
        DispatchQueue.main.async {
            if args.background {
                self.locationManager.requestAlwaysAuthorization()
            } else {
                self.locationManager.requestWhenInUseAuthorization()
            }
            
            // Return current status immediately
            do {
                try self.checkPermissions(invoke)
            } catch {
                invoke.reject(error.localizedDescription)
            }
        }
    }
    
    @objc public func getCurrentLocation(_ invoke: Invoke) throws {
        let args = try? invoke.parseArgs(LocationOptions.self)
        
        guard CLLocationManager.locationServicesEnabled() else {
            invoke.reject("Location services disabled")
            return
        }
        
        guard locationManager.authorizationStatus == .authorizedWhenInUse ||
              locationManager.authorizationStatus == .authorizedAlways else {
            invoke.reject("Location permission denied")
            return
        }
        
        pendingLocationRequest = invoke
        locationOptions = args
        
        // Configure location manager
        if let accuracy = args?.accuracy {
            locationManager.desiredAccuracy = parseAccuracy(accuracy)
        }
        
        if let distanceFilter = args?.distanceFilter {
            locationManager.distanceFilter = distanceFilter
        }
        
        // Check for cached location
        if let maximumAge = args?.maximumAge,
           maximumAge > 0,
           let lastLocation = lastLocation,
           Date().timeIntervalSince(lastLocation.timestamp) * 1000 < Double(maximumAge) {
            invoke.resolve(serializeLocation(lastLocation))
            pendingLocationRequest = nil
            return
        }
        
        // Start timeout timer if specified
        if let timeout = args?.timeout {
            locationUpdateTimer = Timer.scheduledTimer(withTimeInterval: Double(timeout) / 1000.0, repeats: false) { _ in
                self.pendingLocationRequest?.reject("Location timeout")
                self.pendingLocationRequest = nil
                self.locationManager.stopUpdatingLocation()
            }
        }
        
        locationManager.requestLocation()
    }
    
    @objc public func startLocationUpdates(_ invoke: Invoke) throws {
        let args = try? invoke.parseArgs(LocationOptions.self)
        
        guard CLLocationManager.locationServicesEnabled() else {
            invoke.reject("Location services disabled")
            return
        }
        
        guard locationManager.authorizationStatus == .authorizedWhenInUse ||
              locationManager.authorizationStatus == .authorizedAlways else {
            invoke.reject("Location permission denied")
            return
        }
        
        locationOptions = args
        
        // Configure location manager
        if let accuracy = args?.accuracy {
            locationManager.desiredAccuracy = parseAccuracy(accuracy)
        }
        
        if let distanceFilter = args?.distanceFilter {
            locationManager.distanceFilter = distanceFilter
        } else {
            locationManager.distanceFilter = kCLDistanceFilterNone
        }
        
        if args?.showBackgroundLocationIndicator ?? true {
            locationManager.showsBackgroundLocationIndicator = true
        }
        
        locationManager.startUpdatingLocation()
        invoke.resolve()
    }
    
    @objc public func stopLocationUpdates(_ invoke: Invoke) throws {
        locationManager.stopUpdatingLocation()
        invoke.resolve()
    }
    
    @objc public func startMonitoringRegion(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(RegionData.self)
        
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else {
            invoke.reject("Region monitoring not available")
            return
        }
        
        guard locationManager.authorizationStatus == .authorizedAlways else {
            invoke.reject("Always authorization required for region monitoring")
            return
        }
        
        let center = CLLocationCoordinate2D(
            latitude: args.center.latitude,
            longitude: args.center.longitude
        )
        
        let region = CLCircularRegion(
            center: center,
            radius: args.radius,
            identifier: args.identifier
        )
        
        region.notifyOnEntry = args.notifyOnEntry
        region.notifyOnExit = args.notifyOnExit
        
        monitoredRegions[args.identifier] = region
        locationManager.startMonitoring(for: region)
        
        invoke.resolve()
    }
    
    @objc public func stopMonitoringRegion(_ invoke: Invoke) throws {
        struct StopRegionArgs: Decodable {
            let identifier: String
        }
        
        let args = try invoke.parseArgs(StopRegionArgs.self)
        
        if let region = monitoredRegions[args.identifier] {
            locationManager.stopMonitoring(for: region)
            monitoredRegions.removeValue(forKey: args.identifier)
        }
        
        invoke.resolve()
    }
    
    @objc public func geocodeAddress(_ invoke: Invoke) throws {
        struct GeocodeArgs: Decodable {
            let address: String
        }
        
        let args = try invoke.parseArgs(GeocodeArgs.self)
        
        geocoder.geocodeAddressString(args.address) { placemarks, error in
            if let error = error {
                invoke.reject("Geocoding failed: \(error.localizedDescription)")
                return
            }
            
            let results = (placemarks ?? []).compactMap { placemark -> [String: Any]? in
                guard let location = placemark.location else { return nil }
                
                return [
                    "coordinates": [
                        "latitude": location.coordinate.latitude,
                        "longitude": location.coordinate.longitude
                    ],
                    "placemark": self.serializePlacemark(placemark)
                ]
            }
            
            invoke.resolve(results)
        }
    }
    
    @objc public func reverseGeocode(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(CoordinatesData.self)
        
        let location = CLLocation(
            latitude: args.latitude,
            longitude: args.longitude
        )
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                invoke.reject("Reverse geocoding failed: \(error.localizedDescription)")
                return
            }
            
            let results = (placemarks ?? []).map { self.serializePlacemark($0) }
            invoke.resolve(results)
        }
    }
    
    @objc public func getDistance(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(DistanceRequest.self)
        
        let fromLocation = CLLocation(
            latitude: args.from.latitude,
            longitude: args.from.longitude
        )
        
        let toLocation = CLLocation(
            latitude: args.to.latitude,
            longitude: args.to.longitude
        )
        
        let distance = fromLocation.distance(from: toLocation)
        invoke.resolve(distance)
    }
    
    @objc public func startHeadingUpdates(_ invoke: Invoke) throws {
        guard CLLocationManager.headingAvailable() else {
            invoke.reject("Heading not available")
            return
        }
        
        locationManager.startUpdatingHeading()
        invoke.resolve()
    }
    
    @objc public func stopHeadingUpdates(_ invoke: Invoke) throws {
        locationManager.stopUpdatingHeading()
        invoke.resolve()
    }
    
    @objc public func getMonitoredRegions(_ invoke: Invoke) throws {
        let regions = monitoredRegions.values.map { region in
            [
                "identifier": region.identifier,
                "center": [
                    "latitude": region.center.latitude,
                    "longitude": region.center.longitude
                ],
                "radius": region.radius,
                "notifyOnEntry": region.notifyOnEntry,
                "notifyOnExit": region.notifyOnExit
            ]
        }
        
        invoke.resolve(regions)
    }
    
    // MARK: - Helper Methods
    
    private func parseAccuracy(_ accuracy: String) -> CLLocationAccuracy {
        switch accuracy.lowercased() {
        case "best":
            return kCLLocationAccuracyBest
        case "bestfornavigation":
            return kCLLocationAccuracyBestForNavigation
        case "nearesttenmeters":
            return kCLLocationAccuracyNearestTenMeters
        case "hundredmeters":
            return kCLLocationAccuracyHundredMeters
        case "kilometer":
            return kCLLocationAccuracyKilometer
        case "threekilometers":
            return kCLLocationAccuracyThreeKilometers
        case "reduced":
            if #available(iOS 14.0, *) {
                return kCLLocationAccuracyReduced
            } else {
                return kCLLocationAccuracyThreeKilometers
            }
        default:
            return kCLLocationAccuracyBest
        }
    }
    
    private func serializeLocation(_ location: CLLocation) -> [String: Any] {
        var data: [String: Any] = [
            "coordinates": [
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude
            ],
            "accuracy": location.horizontalAccuracy,
            "timestamp": ISO8601DateFormatter().string(from: location.timestamp)
        ]
        
        if location.verticalAccuracy >= 0 {
            data["altitude"] = location.altitude
            data["altitudeAccuracy"] = location.verticalAccuracy
        }
        
        if location.course >= 0 {
            data["heading"] = location.course
        }
        
        if location.speed >= 0 {
            data["speed"] = location.speed
        }
        
        if let floor = location.floor {
            data["floor"] = ["level": floor.level]
        }
        
        return data
    }
    
    private func serializePlacemark(_ placemark: CLPlacemark) -> [String: Any] {
        var data: [String: Any] = [:]
        
        data["name"] = placemark.name
        data["thoroughfare"] = placemark.thoroughfare
        data["subThoroughfare"] = placemark.subThoroughfare
        data["locality"] = placemark.locality
        data["subLocality"] = placemark.subLocality
        data["administrativeArea"] = placemark.administrativeArea
        data["subAdministrativeArea"] = placemark.subAdministrativeArea
        data["postalCode"] = placemark.postalCode
        data["isoCountryCode"] = placemark.isoCountryCode
        data["country"] = placemark.country
        data["inlandWater"] = placemark.inlandWater
        data["ocean"] = placemark.ocean
        data["areasOfInterest"] = placemark.areasOfInterest ?? []
        
        // Create formatted address
        let formatter = CNPostalAddressFormatter()
        if let postalAddress = placemark.postalAddress {
            data["formattedAddress"] = formatter.string(from: postalAddress)
        }
        
        return data
    }
    
    private func authorizationStatusToString(_ status: CLAuthorizationStatus, for usage: CLAuthorizationStatus) -> String {
        switch status {
        case .notDetermined:
            return "prompt"
        case .restricted, .denied:
            return "denied"
        case .authorizedAlways:
            return "granted"
        case .authorizedWhenInUse:
            return usage == .authorizedWhenInUse ? "granted" : "prompt"
        @unknown default:
            return "denied"
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationPlugin: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        lastLocation = location
        
        // Handle one-time location request
        if let invoke = pendingLocationRequest {
            locationUpdateTimer?.invalidate()
            locationUpdateTimer = nil
            invoke.resolve(serializeLocation(location))
            pendingLocationRequest = nil
            manager.stopUpdatingLocation()
        } else {
            // Handle continuous updates
            trigger("locationUpdate", data: serializeLocation(location))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let invoke = pendingLocationRequest {
            locationUpdateTimer?.invalidate()
            locationUpdateTimer = nil
            invoke.reject("Location error: \(error.localizedDescription)")
            pendingLocationRequest = nil
        } else {
            trigger("error", data: ["error": error.localizedDescription])
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let heading: [String: Any] = [
            "magneticHeading": newHeading.magneticHeading,
            "trueHeading": newHeading.trueHeading,
            "headingAccuracy": newHeading.headingAccuracy,
            "timestamp": ISO8601DateFormatter().string(from: newHeading.timestamp)
        ]
        
        trigger("headingUpdate", data: heading)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        trigger("regionEntered", data: ["identifier": region.identifier])
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        trigger("regionExited", data: ["identifier": region.identifier])
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let authStatus = manager.authorizationStatus
        let whenInUse = authorizationStatusToString(authStatus, for: .whenInUse)
        let always = authorizationStatusToString(authStatus, for: .always)
        
        trigger("authorizationChanged", data: [
            "whenInUse": whenInUse,
            "always": always
        ])
    }
}

@_cdecl("init_plugin_ios_location")
func initPlugin() -> Plugin {
    return LocationPlugin()
}