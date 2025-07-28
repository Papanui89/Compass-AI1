import Foundation
import Security

/// Secure storage using iOS Keychain for sensitive data
class SecureStorage {
    static let shared = SecureStorage()
    
    private init() {}
    
    /// Stores data securely in the keychain
    func store(data: Data, key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Delete any existing item
        SecItemDelete(query as CFDictionary)
        
        // Add the new item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw SecureStorageError.saveFailed(status)
        }
    }
    
    /// Retrieves data from the keychain
    func retrieve(key: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            throw SecureStorageError.retrieveFailed(status)
        }
        
        guard let data = result as? Data else {
            throw SecureStorageError.invalidData
        }
        
        return data
    }
    
    /// Stores a string securely
    func store(string: String, key: String) throws {
        guard let data = string.data(using: .utf8) else {
            throw SecureStorageError.encodingFailed
        }
        try store(data: data, key: key)
    }
    
    /// Retrieves a string from secure storage
    func retrieveString(key: String) throws -> String {
        let data = try retrieve(key: key)
        guard let string = String(data: data, encoding: .utf8) else {
            throw SecureStorageError.decodingFailed
        }
        return string
    }
    
    /// Stores a codable object securely
    func store<T: Codable>(_ object: T, key: String) throws {
        let data = try JSONEncoder().encode(object)
        try store(data: data, key: key)
    }
    
    /// Retrieves a codable object from secure storage
    func retrieve<T: Codable>(_ type: T.Type, key: String) throws -> T {
        let data = try retrieve(key: key)
        return try JSONDecoder().decode(type, from: data)
    }
    
    /// Deletes data from the keychain
    func delete(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw SecureStorageError.deleteFailed(status)
        }
    }
    
    /// Checks if a key exists in the keychain
    func exists(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: false,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    /// Clears all stored data
    func clearAll() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw SecureStorageError.deleteFailed(status)
        }
    }
    
    /// Gets all stored keys
    func getAllKeys() throws -> [String] {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecReturnAttributes as String: true,
            kSecMatchLimit as String: kSecMatchLimitAll
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            throw SecureStorageError.retrieveFailed(status)
        }
        
        guard let items = result as? [[String: Any]] else {
            throw SecureStorageError.invalidData
        }
        
        return items.compactMap { $0[kSecAttrAccount as String] as? String }
    }
    
    /// Stores sensitive user data
    func storeUserData(_ userData: UserData) throws {
        try store(userData, key: "user_data")
    }
    
    /// Retrieves sensitive user data
    func retrieveUserData() throws -> UserData? {
        guard exists(key: "user_data") else {
            return nil
        }
        return try retrieve(UserData.self, key: "user_data")
    }
    
    /// Stores encryption keys
    func storeEncryptionKey(_ key: Data, for identifier: String) throws {
        try store(data: key, key: "encryption_key_\(identifier)")
    }
    
    /// Retrieves encryption keys
    func retrieveEncryptionKey(for identifier: String) throws -> Data {
        return try retrieve(key: "encryption_key_\(identifier)")
    }
    
    /// Stores emergency contacts securely
    func storeEmergencyContacts(_ contacts: [EmergencyContact]) throws {
        try store(contacts, key: "emergency_contacts")
    }
    
    /// Retrieves emergency contacts
    func retrieveEmergencyContacts() throws -> [EmergencyContact] {
        guard exists(key: "emergency_contacts") else {
            return []
        }
        return try retrieve([EmergencyContact].self, key: "emergency_contacts")
    }
    
    /// Stores crisis session data
    func storeCrisisSession(_ session: CrisisSession) throws {
        try store(session, key: "crisis_session_\(session.id)")
    }
    
    /// Retrieves crisis session data
    func retrieveCrisisSession(id: String) throws -> CrisisSession? {
        let key = "crisis_session_\(id)"
        guard exists(key: key) else {
            return nil
        }
        return try retrieve(CrisisSession.self, key: key)
    }
    
    /// Stores app settings securely
    func storeAppSettings(_ settings: AppSettings) throws {
        try store(settings, key: "app_settings")
    }
    
    /// Retrieves app settings
    func retrieveAppSettings() throws -> AppSettings? {
        guard exists(key: "app_settings") else {
            return nil
        }
        return try retrieve(AppSettings.self, key: "app_settings")
    }
}

// MARK: - Error Types

enum SecureStorageError: Error, LocalizedError {
    case saveFailed(OSStatus)
    case retrieveFailed(OSStatus)
    case deleteFailed(OSStatus)
    case invalidData
    case encodingFailed
    case decodingFailed
    
    var errorDescription: String? {
        switch self {
        case .saveFailed(let status):
            return "Failed to save data to keychain: \(status)"
        case .retrieveFailed(let status):
            return "Failed to retrieve data from keychain: \(status)"
        case .deleteFailed(let status):
            return "Failed to delete data from keychain: \(status)"
        case .invalidData:
            return "Invalid data format"
        case .encodingFailed:
            return "Failed to encode data"
        case .decodingFailed:
            return "Failed to decode data"
        }
    }
}

// MARK: - Supporting Types

struct UserData: Codable {
    let id: String
    let name: String?
    let email: String?
    let phoneNumber: String?
    let emergencyContacts: [EmergencyContact]
    let preferences: UserPreferences
    let createdAt: Date
    let updatedAt: Date
}

struct EmergencyContact: Codable, Identifiable {
    let id: String
    let name: String
    let phoneNumber: String
    let relationship: String?
    let isPrimary: Bool
    let notificationPreference: NotificationPreference
}

enum NotificationPreference: String, Codable {
    case immediate
    case delayed
    case never
}

struct UserPreferences: Codable {
    let enableNotifications: Bool
    let enableLocationSharing: Bool
    let enableAnalytics: Bool
    let preferredLanguage: String
    let accessibilitySettings: AccessibilitySettings
}

struct AccessibilitySettings: Codable {
    let enableVoiceOver: Bool
    let enableLargeText: Bool
    let enableHighContrast: Bool
    let enableReducedMotion: Bool
}

struct CrisisSession: Codable {
    let id: String
    let type: CrisisType
    let startTime: Date
    let endTime: Date?
    let severity: EmergencyLevel
    let actions: [CrisisAction]
    let outcome: CrisisOutcome
}



enum CrisisOutcome: String, Codable {
    case resolved
    case escalated
    case referred
    case abandoned
}

struct AppSettings: Codable {
    let isFirstLaunch: Bool
    let hasCompletedOnboarding: Bool
    let lastBackupDate: Date?
    let privacySettings: PrivacySettings
    let notificationSettings: NotificationSettings
}

struct PrivacySettings: Codable {
    let enableDataCollection: Bool
    let enableCrashReporting: Bool
    let enableAnalytics: Bool
    let enableLocationTracking: Bool
}

struct NotificationSettings: Codable {
    let enablePushNotifications: Bool
    let enableEmergencyAlerts: Bool
    let enableReminders: Bool
    let quietHours: QuietHours?
}

struct QuietHours: Codable {
    let startTime: Date
    let endTime: Date
    let timeZone: String
} 