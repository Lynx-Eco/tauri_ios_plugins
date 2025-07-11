import Tauri
import Contacts
import UIKit

struct ContactQuery: Decodable {
    let searchText: String?
    let groupId: String?
    let sortOrder: String?
    let includeImages: Bool
    let limit: Int?
}

struct NewContactData: Decodable {
    let givenName: String?
    let familyName: String?
    let middleName: String?
    let nickname: String?
    let prefix: String?
    let suffix: String?
    let organization: String?
    let jobTitle: String?
    let department: String?
    let note: String?
    let birthday: String?
    let phoneNumbers: [[String: String]]?
    let emailAddresses: [[String: String]]?
    let postalAddresses: [[String: String?]]?
    let urlAddresses: [[String: String]]?
    let socialProfiles: [[String: String?]]?
    let instantMessages: [[String: String]]?
    let imageData: String?
}

class ContactsPlugin: Plugin {
    private let store = CNContactStore()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    @objc public override func checkPermissions(_ invoke: Invoke) {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        let permissionState = authorizationStatusToPermissionState(status)
        
        invoke.resolve(["contacts": permissionState])
    }
    
    @objc public override func requestPermissions(_ invoke: Invoke) {
        store.requestAccess(for: .contacts) { granted, error in
            if let error = error {
                invoke.reject(error.localizedDescription)
                return
            }
            
            let permissionState = granted ? "granted" : "denied"
            invoke.resolve(["contacts": permissionState])
        }
    }
    
    @objc public func getContacts(_ invoke: Invoke) throws {
        let args = try? invoke.parseArgs(ContactQuery.self)
        
        guard CNContactStore.authorizationStatus(for: .contacts) == .authorized else {
            invoke.reject("Contacts access denied")
            return
        }
        
        var keysToFetch = defaultKeysToFetch()
        if args?.includeImages ?? false {
            keysToFetch.append(CNContactImageDataKey as CNKeyDescriptor)
            keysToFetch.append(CNContactThumbnailImageDataKey as CNKeyDescriptor)
        }
        
        let request = CNContactFetchRequest(keysToFetch: keysToFetch)
        
        // Apply search filter
        if let searchText = args?.searchText, !searchText.isEmpty {
            request.predicate = CNContact.predicateForContacts(matchingName: searchText)
        }
        
        // Apply sort order
        switch args?.sortOrder {
        case "givenName":
            request.sortOrder = .givenName
        case "familyName":
            request.sortOrder = .familyName
        default:
            request.sortOrder = .none
        }
        
        var contacts: [[String: Any]] = []
        var count = 0
        let limit = args?.limit ?? Int.max
        
        do {
            try store.enumerateContacts(with: request) { contact, stop in
                contacts.append(self.serializeContact(contact, includeImages: args?.includeImages ?? false))
                count += 1
                if count >= limit {
                    stop.pointee = true
                }
            }
            invoke.resolve(["contacts": contacts])
        } catch {
            invoke.reject("Failed to fetch contacts: \(error.localizedDescription)")
        }
    }
    
    @objc public func getContact(_ invoke: Invoke) throws {
        struct GetContactArgs: Decodable {
            let id: String
        }
        
        let args = try invoke.parseArgs(GetContactArgs.self)
        
        guard CNContactStore.authorizationStatus(for: .contacts) == .authorized else {
            invoke.reject("Contacts access denied")
            return
        }
        
        do {
            let keysToFetch = defaultKeysToFetch() + [
                CNContactImageDataKey as CNKeyDescriptor,
                CNContactThumbnailImageDataKey as CNKeyDescriptor
            ]
            
            let contact = try store.unifiedContact(withIdentifier: args.id, keysToFetch: keysToFetch)
            invoke.resolve(serializeContact(contact, includeImages: true))
        } catch {
            invoke.reject("Contact not found")
        }
    }
    
    @objc public func createContact(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(NewContactData.self)
        
        guard CNContactStore.authorizationStatus(for: .contacts) == .authorized else {
            invoke.reject("Contacts access denied")
            return
        }
        
        let contact = CNMutableContact()
        updateContactFromData(contact, data: args)
        
        let saveRequest = CNSaveRequest()
        saveRequest.add(contact, toContainerWithIdentifier: nil)
        
        do {
            try store.execute(saveRequest)
            
            // Fetch the saved contact to get the ID
            let savedContact = try store.unifiedContact(
                withIdentifier: contact.identifier,
                keysToFetch: defaultKeysToFetch()
            )
            invoke.resolve(serializeContact(savedContact, includeImages: false))
        } catch {
            invoke.reject("Failed to save contact: \(error.localizedDescription)")
        }
    }
    
    @objc public func updateContact(_ invoke: Invoke) throws {
        struct UpdateContactArgs: Decodable {
            let id: String
            let givenName: String?
            let familyName: String?
            let middleName: String?
            let nickname: String?
            let prefix: String?
            let suffix: String?
            let organization: String?
            let jobTitle: String?
            let department: String?
            let note: String?
            let birthday: String?
        }
        
        let args = try invoke.parseArgs(UpdateContactArgs.self)
        guard !args.id.isEmpty else {
            invoke.reject("Contact ID is required")
            return
        }
        
        guard CNContactStore.authorizationStatus(for: .contacts) == .authorized else {
            invoke.reject("Contacts access denied")
            return
        }
        
        do {
            let keysToFetch = defaultKeysToFetch()
            let contact = try store.unifiedContact(withIdentifier: args.id, keysToFetch: keysToFetch)
            let mutableContact = contact.mutableCopy() as! CNMutableContact
            
            // Update contact fields from data
            if let givenName = args.givenName {
                mutableContact.givenName = givenName
            }
            if let familyName = args.familyName {
                mutableContact.familyName = familyName
            }
            if let middleName = args.middleName {
                mutableContact.middleName = middleName
            }
            if let nickname = args.nickname {
                mutableContact.nickname = nickname
            }
            if let prefix = args.prefix {
                mutableContact.namePrefix = prefix
            }
            if let suffix = args.suffix {
                mutableContact.nameSuffix = suffix
            }
            if let organization = args.organization {
                mutableContact.organizationName = organization
            }
            if let jobTitle = args.jobTitle {
                mutableContact.jobTitle = jobTitle
            }
            if let department = args.department {
                mutableContact.departmentName = department
            }
            if let note = args.note {
                mutableContact.note = note
            }
            
            let saveRequest = CNSaveRequest()
            saveRequest.update(mutableContact)
            
            try store.execute(saveRequest)
            
            let updatedContact = try store.unifiedContact(
                withIdentifier: mutableContact.identifier,
                keysToFetch: keysToFetch
            )
            invoke.resolve(serializeContact(updatedContact, includeImages: false))
        } catch {
            invoke.reject("Failed to update contact: \(error.localizedDescription)")
        }
    }
    
    @objc public func deleteContact(_ invoke: Invoke) throws {
        struct DeleteContactArgs: Decodable {
            let id: String
        }
        
        let args = try invoke.parseArgs(DeleteContactArgs.self)
        
        guard CNContactStore.authorizationStatus(for: .contacts) == .authorized else {
            invoke.reject("Contacts access denied")
            return
        }
        
        do {
            let keysToFetch = [CNContactIdentifierKey as CNKeyDescriptor]
            let contact = try store.unifiedContact(withIdentifier: args.id, keysToFetch: keysToFetch)
            let mutableContact = contact.mutableCopy() as! CNMutableContact
            
            let saveRequest = CNSaveRequest()
            saveRequest.delete(mutableContact)
            
            try store.execute(saveRequest)
            invoke.resolve()
        } catch {
            invoke.reject("Failed to delete contact: \(error.localizedDescription)")
        }
    }
    
    @objc public func getGroups(_ invoke: Invoke) throws {
        guard CNContactStore.authorizationStatus(for: .contacts) == .authorized else {
            invoke.reject("Contacts access denied")
            return
        }
        
        do {
            let groups = try store.groups(matching: nil)
            let serializedGroups = groups.map { group in
                [
                    "id": group.identifier,
                    "name": group.name,
                    "memberCount": 0 // Would need to count members separately
                ]
            }
            invoke.resolve(["groups": serializedGroups])
        } catch {
            invoke.reject("Failed to fetch groups: \(error.localizedDescription)")
        }
    }
    
    @objc public func createGroup(_ invoke: Invoke) throws {
        struct CreateGroupArgs: Decodable {
            let name: String
        }
        
        let args = try invoke.parseArgs(CreateGroupArgs.self)
        
        guard CNContactStore.authorizationStatus(for: .contacts) == .authorized else {
            invoke.reject("Contacts access denied")
            return
        }
        
        let group = CNMutableGroup()
        group.name = args.name
        
        let saveRequest = CNSaveRequest()
        saveRequest.add(group, toContainerWithIdentifier: nil)
        
        do {
            try store.execute(saveRequest)
            invoke.resolve([
                "id": group.identifier,
                "name": group.name,
                "memberCount": 0
            ])
        } catch {
            invoke.reject("Failed to create group: \(error.localizedDescription)")
        }
    }
    
    @objc public func updateGroup(_ invoke: Invoke) throws {
        struct UpdateGroupArgs: Decodable {
            let groupId: String
            let name: String
        }
        
        let args = try invoke.parseArgs(UpdateGroupArgs.self)
        
        guard CNContactStore.authorizationStatus(for: .contacts) == .authorized else {
            invoke.reject("Contacts access denied")
            return
        }
        
        do {
            let groups = try store.groups(matching: CNGroup.predicateForGroups(withIdentifiers: [args.groupId]))
            guard let group = groups.first else {
                invoke.reject("Group not found")
                return
            }
            
            let mutableGroup = group.mutableCopy() as! CNMutableGroup
            mutableGroup.name = args.name
            
            let saveRequest = CNSaveRequest()
            saveRequest.update(mutableGroup)
            
            try store.execute(saveRequest)
            invoke.resolve([
                "id": mutableGroup.identifier,
                "name": mutableGroup.name,
                "memberCount": 0
            ])
        } catch {
            invoke.reject("Failed to update group: \(error.localizedDescription)")
        }
    }
    
    @objc public func deleteGroup(_ invoke: Invoke) throws {
        struct DeleteGroupArgs: Decodable {
            let groupId: String
        }
        
        let args = try invoke.parseArgs(DeleteGroupArgs.self)
        
        guard CNContactStore.authorizationStatus(for: .contacts) == .authorized else {
            invoke.reject("Contacts access denied")
            return
        }
        
        do {
            let groups = try store.groups(matching: CNGroup.predicateForGroups(withIdentifiers: [args.groupId]))
            guard let group = groups.first else {
                invoke.reject("Group not found")
                return
            }
            
            let mutableGroup = group.mutableCopy() as! CNMutableGroup
            
            let saveRequest = CNSaveRequest()
            saveRequest.delete(mutableGroup)
            
            try store.execute(saveRequest)
            invoke.resolve()
        } catch {
            invoke.reject("Failed to delete group: \(error.localizedDescription)")
        }
    }
    
    @objc public func addContactToGroup(_ invoke: Invoke) throws {
        struct AddContactToGroupArgs: Decodable {
            let contactId: String
            let groupId: String
        }
        
        let args = try invoke.parseArgs(AddContactToGroupArgs.self)
        
        guard CNContactStore.authorizationStatus(for: .contacts) == .authorized else {
            invoke.reject("Contacts access denied")
            return
        }
        
        do {
            let groups = try store.groups(matching: CNGroup.predicateForGroups(withIdentifiers: [args.groupId]))
            guard let group = groups.first else {
                invoke.reject("Group not found")
                return
            }
            
            let keysToFetch = [CNContactIdentifierKey as CNKeyDescriptor]
            let contact = try store.unifiedContact(withIdentifier: args.contactId, keysToFetch: keysToFetch)
            
            let saveRequest = CNSaveRequest()
            saveRequest.addMember(contact, to: group)
            
            try store.execute(saveRequest)
            invoke.resolve()
        } catch {
            invoke.reject("Failed to add contact to group: \(error.localizedDescription)")
        }
    }
    
    @objc public func removeContactFromGroup(_ invoke: Invoke) throws {
        struct RemoveContactFromGroupArgs: Decodable {
            let contactId: String
            let groupId: String
        }
        
        let args = try invoke.parseArgs(RemoveContactFromGroupArgs.self)
        
        guard CNContactStore.authorizationStatus(for: .contacts) == .authorized else {
            invoke.reject("Contacts access denied")
            return
        }
        
        do {
            let groups = try store.groups(matching: CNGroup.predicateForGroups(withIdentifiers: [args.groupId]))
            guard let group = groups.first else {
                invoke.reject("Group not found")
                return
            }
            
            let keysToFetch = [CNContactIdentifierKey as CNKeyDescriptor]
            let contact = try store.unifiedContact(withIdentifier: args.contactId, keysToFetch: keysToFetch)
            
            let saveRequest = CNSaveRequest()
            saveRequest.removeMember(contact, from: group)
            
            try store.execute(saveRequest)
            invoke.resolve()
        } catch {
            invoke.reject("Failed to remove contact from group: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Helper Methods
    
    private func defaultKeysToFetch() -> [CNKeyDescriptor] {
        return [
            CNContactIdentifierKey,
            CNContactGivenNameKey,
            CNContactFamilyNameKey,
            CNContactMiddleNameKey,
            CNContactNicknameKey,
            CNContactNamePrefixKey,
            CNContactNameSuffixKey,
            CNContactOrganizationNameKey,
            CNContactJobTitleKey,
            CNContactDepartmentNameKey,
            CNContactNoteKey,
            CNContactBirthdayKey,
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey,
            CNContactPostalAddressesKey,
            CNContactUrlAddressesKey,
            CNContactSocialProfilesKey,
            CNContactInstantMessageAddressesKey
        ] as [CNKeyDescriptor]
    }
    
    private func serializeContact(_ contact: CNContact, includeImages: Bool) -> [String: Any] {
        var data: [String: Any] = [
            "id": contact.identifier,
            "givenName": contact.givenName.isEmpty ? nil : contact.givenName,
            "familyName": contact.familyName.isEmpty ? nil : contact.familyName,
            "middleName": contact.middleName.isEmpty ? nil : contact.middleName,
            "nickname": contact.nickname.isEmpty ? nil : contact.nickname,
            "prefix": contact.namePrefix.isEmpty ? nil : contact.namePrefix,
            "suffix": contact.nameSuffix.isEmpty ? nil : contact.nameSuffix,
            "organization": contact.organizationName.isEmpty ? nil : contact.organizationName,
            "jobTitle": contact.jobTitle.isEmpty ? nil : contact.jobTitle,
            "department": contact.departmentName.isEmpty ? nil : contact.departmentName,
            "note": contact.note.isEmpty ? nil : contact.note,
            "birthday": contact.birthday != nil ? dateFormatter.string(from: contact.birthday!.date!) : nil
        ]
        
        // Phone numbers
        data["phoneNumbers"] = contact.phoneNumbers.map { phone in
            [
                "label": CNLabeledValue<NSString>.localizedString(forLabel: phone.label ?? ""),
                "value": phone.value.stringValue
            ]
        }
        
        // Email addresses
        data["emailAddresses"] = contact.emailAddresses.map { email in
            [
                "label": CNLabeledValue<NSString>.localizedString(forLabel: email.label ?? ""),
                "value": email.value as String
            ]
        }
        
        // Postal addresses
        data["postalAddresses"] = contact.postalAddresses.map { address in
            [
                "label": CNLabeledValue<NSString>.localizedString(forLabel: address.label ?? ""),
                "street": address.value.street,
                "city": address.value.city,
                "state": address.value.state,
                "postalCode": address.value.postalCode,
                "country": address.value.country
            ]
        }
        
        // URL addresses
        data["urlAddresses"] = contact.urlAddresses.map { url in
            [
                "label": CNLabeledValue<NSString>.localizedString(forLabel: url.label ?? ""),
                "value": url.value as String
            ]
        }
        
        // Images
        if includeImages {
            if contact.imageDataAvailable, let imageData = contact.imageData {
                data["imageData"] = imageData.base64EncodedString()
            }
            if contact.imageDataAvailable, let thumbnailData = contact.thumbnailImageData {
                data["thumbnailImageData"] = thumbnailData.base64EncodedString()
            }
        }
        
        return data
    }
    
    private func updateContactFromData(_ contact: CNMutableContact, data: NewContactData) {
        if let givenName = data.givenName {
            contact.givenName = givenName
        }
        if let familyName = data.familyName {
            contact.familyName = familyName
        }
        if let middleName = data.middleName {
            contact.middleName = middleName
        }
        if let nickname = data.nickname {
            contact.nickname = nickname
        }
        if let prefix = data.prefix {
            contact.namePrefix = prefix
        }
        if let suffix = data.suffix {
            contact.nameSuffix = suffix
        }
        if let organization = data.organization {
            contact.organizationName = organization
        }
        if let jobTitle = data.jobTitle {
            contact.jobTitle = jobTitle
        }
        if let department = data.department {
            contact.departmentName = department
        }
        if let note = data.note {
            contact.note = note
        }
        
        // Birthday
        if let birthdayString = data.birthday,
           let date = dateFormatter.date(from: birthdayString) {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            contact.birthday = components
        }
        
        // Phone numbers
        if let phoneNumbers = data.phoneNumbers {
            contact.phoneNumbers = phoneNumbers.compactMap { dict in
                guard let label = dict["label"],
                      let value = dict["value"] else { return nil }
                return CNLabeledValue(label: label, value: CNPhoneNumber(stringValue: value))
            }
        }
        
        // Email addresses
        if let emailAddresses = data.emailAddresses {
            contact.emailAddresses = emailAddresses.compactMap { dict in
                guard let label = dict["label"],
                      let value = dict["value"] else { return nil }
                return CNLabeledValue(label: label, value: value as NSString)
            }
        }
        
        // Image data
        if let imageDataString = data.imageData,
           let imageData = Data(base64Encoded: imageDataString) {
            contact.imageData = imageData
        }
    }
    
    private func authorizationStatusToPermissionState(_ status: CNAuthorizationStatus) -> String {
        switch status {
        case .notDetermined:
            return "prompt"
        case .restricted, .denied:
            return "denied"
        case .authorized:
            return "granted"
        @unknown default:
            // This handles .limited on iOS 18+ and any future cases
            if #available(iOS 18.0, *) {
                // Check if it's the limited case
                return "limited"
            }
            return "denied"
        }
    }
}

@_cdecl("init_plugin_ios_contacts")
func initPlugin() -> Plugin {
    return ContactsPlugin()
}