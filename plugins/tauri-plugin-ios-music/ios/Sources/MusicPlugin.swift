import Tauri
import WebKit
import MediaPlayer
import MusicKit
import UIKit

struct PlaylistQuery: Decodable {
    let isEditable: Bool?
    let author: String?
    let sortOrder: String?
}

struct SongQuery: Decodable {
    let artistId: String?
    let albumId: String?
    let playlistId: String?
    let genre: String?
    let searchText: String?
    let isCloudItem: Bool?
    let sortOrder: String?
    let limit: Int?
    let offset: Int?
}

struct AlbumQuery: Decodable {
    let artistId: String?
    let genre: String?
    let searchText: String?
    let isCompilation: Bool?
    let sortOrder: String?
    let limit: Int?
    let offset: Int?
}

struct ArtistQuery: Decodable {
    let genre: String?
    let searchText: String?
    let sortOrder: String?
    let limit: Int?
    let offset: Int?
}

struct CreatePlaylistData: Decodable {
    let name: String
    let description: String?
    let songIds: [String]
}

struct PlayableItemData: Decodable {
    let type: String
    let id: String?
    let songIds: [String]?
}

struct SearchQueryData: Decodable {
    let term: String
    let types: [String]
    let limit: Int?
    let storefront: String?
}

class MusicPlugin: Plugin {
    private let musicPlayer = MPMusicPlayerController.applicationMusicPlayer
    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    @objc public override func load(webview: WKWebView) {
        super.load(webview: webview)
        
        // Setup music player notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playbackStateChanged),
            name: .MPMusicPlayerControllerPlaybackStateDidChange,
            object: musicPlayer
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(nowPlayingItemChanged),
            name: .MPMusicPlayerControllerNowPlayingItemDidChange,
            object: musicPlayer
        )
        
        musicPlayer.beginGeneratingPlaybackNotifications()
    }
    
    deinit {
        musicPlayer.endGeneratingPlaybackNotifications()
    }
    
    @objc public func checkPermissions(_ invoke: Invoke) throws {
        let mediaLibraryStatus = MPMediaLibrary.authorizationStatus()
        
        var musicKitStatus = "prompt"
        if #available(iOS 15.0, *) {
            Task {
                let status = await MusicAuthorization.currentStatus
                musicKitStatus = self.musicAuthorizationStatusToString(status)
                
                invoke.resolve([
                    "mediaLibrary": self.mediaLibraryStatusToString(mediaLibraryStatus),
                    "appleMusic": musicKitStatus
                ])
            }
        } else {
            invoke.resolve([
                "mediaLibrary": mediaLibraryStatusToString(mediaLibraryStatus),
                "appleMusic": "denied"
            ])
        }
    }
    
    @objc public func requestPermissions(_ invoke: Invoke) throws {
        MPMediaLibrary.requestAuthorization { [weak self] status in
            if #available(iOS 15.0, *) {
                Task {
                    let musicKitStatus = await MusicAuthorization.request()
                    
                    invoke.resolve([
                        "mediaLibrary": self?.mediaLibraryStatusToString(status) ?? "denied",
                        "appleMusic": self?.musicAuthorizationStatusToString(musicKitStatus) ?? "denied"
                    ])
                }
            } else {
                invoke.resolve([
                    "mediaLibrary": self?.mediaLibraryStatusToString(status) ?? "denied",
                    "appleMusic": "denied"
                ])
            }
        }
    }
    
    @objc public func getLibraryStatus(_ invoke: Invoke) throws {
        guard MPMediaLibrary.authorizationStatus() == .authorized else {
            invoke.reject("Music library access denied")
            return
        }
        
        let songs = MPMediaQuery.songs().items ?? []
        let albums = MPMediaQuery.albums().collections ?? []
        let artists = MPMediaQuery.artists().collections ?? []
        let playlists = MPMediaQuery.playlists().collections ?? []
        
        var hasAppleMusic = false
        if #available(iOS 15.0, *) {
            if MusicAuthorization.currentStatus == .authorized {
                hasAppleMusic = true
            }
        }
        
        invoke.resolve([
            "isCloudEnabled": MPMediaLibrary.default().isCloudLibraryEnabled,
            "hasAppleMusicSubscription": hasAppleMusic,
            "songCount": songs.count,
            "albumCount": albums.count,
            "artistCount": artists.count,
            "playlistCount": playlists.count
        ])
    }
    
    @objc public func getPlaylists(_ invoke: Invoke) throws {
        let args = try? invoke.parseArgs(PlaylistQuery.self)
        
        guard MPMediaLibrary.authorizationStatus() == .authorized else {
            invoke.reject("Music library access denied")
            return
        }
        
        let query = MPMediaQuery.playlists()
        
        if let author = args?.author {
            query.addFilterPredicate(MPMediaPropertyPredicate(
                value: author,
                forProperty: MPMediaPlaylistPropertyAuthorName
            ))
        }
        
        let playlists = (query.collections ?? []).compactMap { collection -> [String: Any]? in
            guard let playlist = collection as? MPMediaPlaylist else { return nil }
            return serializePlaylist(playlist)
        }
        
        invoke.resolve(playlists)
    }
    
    @objc public func getPlaylist(_ invoke: Invoke) throws {
        struct GetPlaylistArgs: Decodable {
            let id: String
        }
        
        let args = try invoke.parseArgs(GetPlaylistArgs.self)
        
        guard MPMediaLibrary.authorizationStatus() == .authorized else {
            invoke.reject("Music library access denied")
            return
        }
        
        let query = MPMediaQuery.playlists()
        query.addFilterPredicate(MPMediaPropertyPredicate(
            value: UInt64(args.id),
            forProperty: MPMediaPlaylistPropertyPersistentID
        ))
        
        guard let playlist = query.collections?.first as? MPMediaPlaylist else {
            invoke.reject("Playlist not found")
            return
        }
        
        var result = serializePlaylist(playlist)
        result["songs"] = playlist.items.map { serializeSong($0) }
        
        invoke.resolve(result)
    }
    
    @objc public func createPlaylist(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(CreatePlaylistData.self)
        
        guard MPMediaLibrary.authorizationStatus() == .authorized else {
            invoke.reject("Music library access denied")
            return
        }
        
        // Get songs by IDs
        let songIds = args.songIds.compactMap { UInt64($0) }
        let songs = songIds.compactMap { id -> MPMediaItem? in
            let query = MPMediaQuery.songs()
            query.addFilterPredicate(MPMediaPropertyPredicate(
                value: id,
                forProperty: MPMediaItemPropertyPersistentID
            ))
            return query.items?.first
        }
        
        // Create playlist metadata
        let metadata: [String: Any] = [
            MPMediaPlaylistPropertyName: args.name,
            MPMediaPlaylistPropertyDescriptionText: args.description ?? ""
        ]
        
        // Create playlist
        MPMediaLibrary.default().getPlaylist(
            with: UUID(),
            creationMetadata: MPMediaPlaylistCreationMetadata(metadata: metadata)
        ) { playlist, error in
            if let error = error {
                invoke.reject("Failed to create playlist: \(error.localizedDescription)")
                return
            }
            
            guard let playlist = playlist else {
                invoke.reject("Failed to create playlist")
                return
            }
            
            // Add songs to playlist
            if !songs.isEmpty {
                playlist.add(songs) { error in
                    if let error = error {
                        invoke.reject("Failed to add songs: \(error.localizedDescription)")
                    } else {
                        invoke.resolve(self.serializePlaylist(playlist))
                    }
                }
            } else {
                invoke.resolve(self.serializePlaylist(playlist))
            }
        }
    }
    
    @objc public func getSongs(_ invoke: Invoke) throws {
        let args = try? invoke.parseArgs(SongQuery.self)
        
        guard MPMediaLibrary.authorizationStatus() == .authorized else {
            invoke.reject("Music library access denied")
            return
        }
        
        let query = MPMediaQuery.songs()
        
        // Apply filters
        if let artistId = args?.artistId,
           let id = UInt64(artistId) {
            query.addFilterPredicate(MPMediaPropertyPredicate(
                value: id,
                forProperty: MPMediaItemPropertyArtistPersistentID
            ))
        }
        
        if let albumId = args?.albumId,
           let id = UInt64(albumId) {
            query.addFilterPredicate(MPMediaPropertyPredicate(
                value: id,
                forProperty: MPMediaItemPropertyAlbumPersistentID
            ))
        }
        
        if let genre = args?.genre {
            query.addFilterPredicate(MPMediaPropertyPredicate(
                value: genre,
                forProperty: MPMediaItemPropertyGenre
            ))
        }
        
        if let searchText = args?.searchText {
            let predicates = [
                MPMediaPropertyPredicate(value: searchText, forProperty: MPMediaItemPropertyTitle, comparisonType: .contains),
                MPMediaPropertyPredicate(value: searchText, forProperty: MPMediaItemPropertyArtist, comparisonType: .contains),
                MPMediaPropertyPredicate(value: searchText, forProperty: MPMediaItemPropertyAlbumTitle, comparisonType: .contains)
            ]
            query.filterPredicates = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        }
        
        if let isCloudItem = args?.isCloudItem {
            query.addFilterPredicate(MPMediaPropertyPredicate(
                value: isCloudItem,
                forProperty: MPMediaItemPropertyIsCloudItem
            ))
        }
        
        let items = query.items ?? []
        var songs = items.map { serializeSong($0) }
        
        // Apply limit and offset
        if let offset = args?.offset {
            songs = Array(songs.dropFirst(offset))
        }
        if let limit = args?.limit {
            songs = Array(songs.prefix(limit))
        }
        
        invoke.resolve(songs)
    }
    
    @objc public func getAlbums(_ invoke: Invoke) throws {
        let args = try? invoke.parseArgs(AlbumQuery.self)
        
        guard MPMediaLibrary.authorizationStatus() == .authorized else {
            invoke.reject("Music library access denied")
            return
        }
        
        let query = MPMediaQuery.albums()
        
        // Apply filters
        if let artistId = args?.artistId,
           let id = UInt64(artistId) {
            query.addFilterPredicate(MPMediaPropertyPredicate(
                value: id,
                forProperty: MPMediaItemPropertyArtistPersistentID
            ))
        }
        
        if let genre = args?.genre {
            query.addFilterPredicate(MPMediaPropertyPredicate(
                value: genre,
                forProperty: MPMediaItemPropertyGenre
            ))
        }
        
        if let isCompilation = args?.isCompilation {
            query.addFilterPredicate(MPMediaPropertyPredicate(
                value: isCompilation,
                forProperty: MPMediaItemPropertyIsCompilation
            ))
        }
        
        let collections = query.collections ?? []
        var albums = collections.compactMap { collection -> [String: Any]? in
            guard let item = collection.representativeItem else { return nil }
            return serializeAlbum(item, itemCount: collection.count)
        }
        
        // Apply limit and offset
        if let offset = args?.offset {
            albums = Array(albums.dropFirst(offset))
        }
        if let limit = args?.limit {
            albums = Array(albums.prefix(limit))
        }
        
        invoke.resolve(albums)
    }
    
    @objc public func getArtists(_ invoke: Invoke) throws {
        let args = try? invoke.parseArgs(ArtistQuery.self)
        
        guard MPMediaLibrary.authorizationStatus() == .authorized else {
            invoke.reject("Music library access denied")
            return
        }
        
        let query = MPMediaQuery.artists()
        
        if let genre = args?.genre {
            query.addFilterPredicate(MPMediaPropertyPredicate(
                value: genre,
                forProperty: MPMediaItemPropertyGenre
            ))
        }
        
        let collections = query.collections ?? []
        var artists = collections.compactMap { collection -> [String: Any]? in
            guard let item = collection.representativeItem else { return nil }
            return serializeArtist(item, itemCount: collection.count)
        }
        
        // Apply limit and offset
        if let offset = args?.offset {
            artists = Array(artists.dropFirst(offset))
        }
        if let limit = args?.limit {
            artists = Array(artists.prefix(limit))
        }
        
        invoke.resolve(artists)
    }
    
    @objc public func playItem(_ invoke: Invoke) throws {
        let data = invoke.data as? [String: Any] ?? [:]
        let type = data["type"] as? String ?? ""
        
        switch type {
        case "song":
            if let id = data["id"] as? String,
               let persistentId = UInt64(id) {
                let query = MPMediaQuery.songs()
                query.addFilterPredicate(MPMediaPropertyPredicate(
                    value: persistentId,
                    forProperty: MPMediaItemPropertyPersistentID
                ))
                
                if let item = query.items?.first {
                    musicPlayer.setQueue(with: MPMediaItemCollection(items: [item]))
                    musicPlayer.play()
                    invoke.resolve()
                } else {
                    invoke.reject("Song not found")
                }
            }
            
        case "album":
            if let id = data["id"] as? String,
               let persistentId = UInt64(id) {
                let query = MPMediaQuery.albums()
                query.addFilterPredicate(MPMediaPropertyPredicate(
                    value: persistentId,
                    forProperty: MPMediaItemPropertyAlbumPersistentID
                ))
                
                if let collection = query.collections?.first {
                    musicPlayer.setQueue(with: collection)
                    musicPlayer.play()
                    invoke.resolve()
                } else {
                    invoke.reject("Album not found")
                }
            }
            
        case "playlist":
            if let id = data["id"] as? String,
               let persistentId = UInt64(id) {
                let query = MPMediaQuery.playlists()
                query.addFilterPredicate(MPMediaPropertyPredicate(
                    value: persistentId,
                    forProperty: MPMediaPlaylistPropertyPersistentID
                ))
                
                if let playlist = query.collections?.first {
                    musicPlayer.setQueue(with: playlist)
                    musicPlayer.play()
                    invoke.resolve()
                } else {
                    invoke.reject("Playlist not found")
                }
            }
            
        case "queue":
            if let songIds = data["songIds"] as? [String] {
                let persistentIds = songIds.compactMap { UInt64($0) }
                let items = persistentIds.compactMap { id -> MPMediaItem? in
                    let query = MPMediaQuery.songs()
                    query.addFilterPredicate(MPMediaPropertyPredicate(
                        value: id,
                        forProperty: MPMediaItemPropertyPersistentID
                    ))
                    return query.items?.first
                }
                
                if !items.isEmpty {
                    musicPlayer.setQueue(with: MPMediaItemCollection(items: items))
                    musicPlayer.play()
                    invoke.resolve()
                } else {
                    invoke.reject("No valid songs found")
                }
            }
            
        default:
            invoke.reject("Invalid playable item type")
        }
    }
    
    @objc public func pause(_ invoke: Invoke) throws {
        musicPlayer.pause()
        invoke.resolve()
    }
    
    @objc public func resume(_ invoke: Invoke) throws {
        musicPlayer.play()
        invoke.resolve()
    }
    
    @objc public func getPlaybackState(_ invoke: Invoke) throws {
        invoke.resolve([
            "status": playbackStatusToString(musicPlayer.playbackState),
            "currentTime": musicPlayer.currentPlaybackTime,
            "repeatMode": repeatModeToString(musicPlayer.repeatMode),
            "shuffleMode": shuffleModeToString(musicPlayer.shuffleMode),
            "playbackRate": musicPlayer.currentPlaybackRate,
            "volume": AVAudioSession.sharedInstance().outputVolume
        ])
    }
    
    @objc public func getNowPlaying(_ invoke: Invoke) throws {
        guard let nowPlaying = musicPlayer.nowPlayingItem else {
            invoke.resolve(nil)
            return
        }
        
        let currentTime = musicPlayer.currentPlaybackTime
        let duration = nowPlaying.playbackDuration
        
        invoke.resolve([
            "item": serializeSong(nowPlaying),
            "index": musicPlayer.indexOfNowPlayingItem,
            "queueCount": 0, // Not directly available
            "elapsedTime": currentTime,
            "remainingTime": duration - currentTime
        ])
    }
    
    @objc public func searchCatalog(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(SearchQueryData.self)
        
        guard #available(iOS 15.0, *) else {
            invoke.reject("Apple Music search requires iOS 15.0+")
            return
        }
        
        Task {
            do {
                var request = MusicCatalogSearchRequest(term: args.term, types: [Song.self, Album.self, Artist.self, Playlist.self])
                if let limit = args.limit {
                    request.limit = limit
                }
                
                let response = try await request.response()
                
                var results: [String: [[String: Any]]] = [
                    "songs": [],
                    "albums": [],
                    "artists": [],
                    "playlists": []
                ]
                
                // Process songs
                results["songs"] = response.songs.map { song in
                    [
                        "id": song.id.rawValue,
                        "name": song.title,
                        "artistName": song.artistName,
                        "artworkUrl": song.artwork?.url(width: 300, height: 300)?.absoluteString,
                        "previewUrl": song.previewAssets?.first?.url?.absoluteString,
                        "isExplicit": song.contentRating == .explicit
                    ]
                }
                
                // Process albums
                results["albums"] = response.albums.map { album in
                    [
                        "id": album.id.rawValue,
                        "name": album.title,
                        "artistName": album.artistName,
                        "artworkUrl": album.artwork?.url(width: 300, height: 300)?.absoluteString,
                        "isExplicit": album.contentRating == .explicit
                    ]
                }
                
                // Process artists
                results["artists"] = response.artists.map { artist in
                    [
                        "id": artist.id.rawValue,
                        "name": artist.name,
                        "artworkUrl": artist.artwork?.url(width: 300, height: 300)?.absoluteString
                    ]
                }
                
                // Process playlists
                results["playlists"] = response.playlists.map { playlist in
                    [
                        "id": playlist.id.rawValue,
                        "name": playlist.name,
                        "artistName": playlist.curatorName,
                        "artworkUrl": playlist.artwork?.url(width: 300, height: 300)?.absoluteString
                    ]
                }
                
                invoke.resolve(results)
            } catch {
                invoke.reject("Search failed: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func serializeSong(_ item: MPMediaItem) -> [String: Any] {
        var data: [String: Any] = [
            "id": String(item.persistentID),
            "title": item.title ?? "Unknown",
            "artist": item.artist ?? "Unknown Artist",
            "album": item.albumTitle ?? "Unknown Album",
            "albumArtist": item.albumArtist,
            "genre": item.genre,
            "composer": item.composer,
            "duration": item.playbackDuration,
            "trackNumber": item.albumTrackNumber,
            "discNumber": item.discNumber,
            "year": item.year,
            "isExplicit": item.isExplicitItem,
            "isCloudItem": item.isCloudItem,
            "hasLyrics": item.lyrics != nil,
            "playCount": item.playCount,
            "skipCount": item.skipCount,
            "rating": item.rating,
            "dateAdded": dateFormatter.string(from: item.dateAdded)
        ]
        
        if let artwork = item.artwork,
           let image = artwork.image(at: CGSize(width: 300, height: 300)) {
            if let imageData = image.pngData() {
                data["artworkUrl"] = "data:image/png;base64,\(imageData.base64EncodedString())"
            }
        }
        
        if let lastPlayed = item.lastPlayedDate {
            data["lastPlayedDate"] = dateFormatter.string(from: lastPlayed)
        }
        
        return data
    }
    
    private func serializeAlbum(_ item: MPMediaItem, itemCount: Int) -> [String: Any] {
        var data: [String: Any] = [
            "id": String(item.albumPersistentID),
            "title": item.albumTitle ?? "Unknown Album",
            "artist": item.albumArtist ?? item.artist ?? "Unknown Artist",
            "albumArtist": item.albumArtist,
            "genre": item.genre,
            "year": item.year,
            "trackCount": itemCount,
            "isCompilation": item.isCompilation,
            "isExplicit": item.isExplicitItem
        ]
        
        if let artwork = item.artwork,
           let image = artwork.image(at: CGSize(width: 300, height: 300)) {
            if let imageData = image.pngData() {
                data["artworkUrl"] = "data:image/png;base64,\(imageData.base64EncodedString())"
            }
        }
        
        return data
    }
    
    private func serializeArtist(_ item: MPMediaItem, itemCount: Int) -> [String: Any] {
        var data: [String: Any] = [
            "id": String(item.artistPersistentID),
            "name": item.artist ?? "Unknown Artist",
            "genre": item.genre,
            "albumCount": 0, // Would need separate query
            "songCount": itemCount
        ]
        
        if let artwork = item.artwork,
           let image = artwork.image(at: CGSize(width: 300, height: 300)) {
            if let imageData = image.pngData() {
                data["artworkUrl"] = "data:image/png;base64,\(imageData.base64EncodedString())"
            }
        }
        
        return data
    }
    
    private func serializePlaylist(_ playlist: MPMediaPlaylist) -> [String: Any] {
        return [
            "id": String(playlist.persistentID),
            "name": playlist.name ?? "Untitled Playlist",
            "description": playlist.descriptionText,
            "author": playlist.authorDisplayName,
            "isEditable": playlist.playlistAttributes.contains(.onTheGo),
            "isPublic": false,
            "songCount": playlist.count,
            "duration": playlist.items.reduce(0.0) { $0 + $1.playbackDuration },
            "dateCreated": dateFormatter.string(from: Date()), // Not available
            "dateModified": dateFormatter.string(from: Date()) // Not available
        ]
    }
    
    private func mediaLibraryStatusToString(_ status: MPMediaLibraryAuthorizationStatus) -> String {
        switch status {
        case .notDetermined:
            return "prompt"
        case .denied, .restricted:
            return "denied"
        case .authorized:
            return "granted"
        @unknown default:
            return "denied"
        }
    }
    
    @available(iOS 15.0, *)
    private func musicAuthorizationStatusToString(_ status: MusicAuthorization.Status) -> String {
        switch status {
        case .notDetermined:
            return "prompt"
        case .denied, .restricted:
            return "denied"
        case .authorized:
            return "granted"
        @unknown default:
            return "denied"
        }
    }
    
    private func playbackStatusToString(_ state: MPMusicPlaybackState) -> String {
        switch state {
        case .stopped:
            return "stopped"
        case .playing:
            return "playing"
        case .paused:
            return "paused"
        case .interrupted:
            return "interrupted"
        case .seekingForward:
            return "seekingForward"
        case .seekingBackward:
            return "seekingBackward"
        @unknown default:
            return "stopped"
        }
    }
    
    private func repeatModeToString(_ mode: MPMusicRepeatMode) -> String {
        switch mode {
        case .none:
            return "none"
        case .one:
            return "one"
        case .all:
            return "all"
        default:
            return "none"
        }
    }
    
    private func shuffleModeToString(_ mode: MPMusicShuffleMode) -> String {
        switch mode {
        case .off:
            return "off"
        case .songs:
            return "songs"
        case .albums:
            return "albums"
        default:
            return "off"
        }
    }
    
    // MARK: - Notifications
    
    @objc private func playbackStateChanged() {
        trigger("playbackStateChanged", data: [
            "status": playbackStatusToString(musicPlayer.playbackState)
        ])
    }
    
    @objc private func nowPlayingItemChanged() {
        if let item = musicPlayer.nowPlayingItem {
            trigger("nowPlayingChanged", data: serializeSong(item))
        } else {
            trigger("nowPlayingChanged", data: nil)
        }
    }
}

@_cdecl("init_plugin_ios_music")
func initPlugin() -> Plugin {
    return MusicPlugin()
}