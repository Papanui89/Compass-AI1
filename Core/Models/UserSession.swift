import Foundation
import CoreLocation
import UIKit

/// Represents a user session with app usage and crisis interaction data
struct UserSession: Identifiable, Codable {
    let id: String
    let userId: String?
    let startTime: Date
    let endTime: Date?
    let duration: TimeInterval
    let appVersion: String
    let deviceInfo: DeviceInfo
    let location: CLLocationCoordinate2D?
    let interactions: [UserInteraction]
    let crisisEvents: [CrisisEvent]
    let settings: SessionSettings
    let metadata: SessionMetadata
    
    init(
        id: String = UUID().uuidString,
        userId: String? = nil,
        startTime: Date = Date(),
        endTime: Date? = nil,
        duration: TimeInterval = 0,
        appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
        deviceInfo: DeviceInfo = DeviceInfo(model: UIDevice.current.model, systemVersion: UIDevice.current.systemVersion, appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"),
        location: CLLocationCoordinate2D? = nil,
        interactions: [UserInteraction] = [],
        crisisEvents: [CrisisEvent] = [],
        settings: SessionSettings = SessionSettings(),
        metadata: SessionMetadata = SessionMetadata()
    ) {
        self.id = id
        self.userId = userId
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.appVersion = appVersion
        self.deviceInfo = deviceInfo
        self.location = location
        self.interactions = interactions
        self.crisisEvents = crisisEvents
        self.settings = settings
        self.metadata = metadata
    }
}

struct UserInteraction: Identifiable, Codable {
    let id: String
    let type: InteractionType
    let timestamp: Date
    let screen: String?
    let action: String?
    let data: [String: String]
    let duration: TimeInterval?
    
    init(
        id: String = UUID().uuidString,
        type: InteractionType,
        timestamp: Date = Date(),
        screen: String? = nil,
        action: String? = nil,
        data: [String: String] = [:],
        duration: TimeInterval? = nil
    ) {
        self.id = id
        self.type = type
        self.timestamp = timestamp
        self.screen = screen
        self.action = action
        self.data = data
        self.duration = duration
    }
}

enum InteractionType: String, Codable, CaseIterable {
    case appLaunch = "app_launch"
    case screenView = "screen_view"
    case buttonTap = "button_tap"
    case textInput = "text_input"
    case flowStart = "flow_start"
    case flowComplete = "flow_complete"
    case crisisReport = "crisis_report"
    case emergencyCall = "emergency_call"
    case emergencyAction = "emergency_action"
    case resourceAccess = "resource_access"
    case settingsChange = "settings_change"
    case appClose = "app_close"
    
    var displayName: String {
        switch self {
        case .appLaunch:
            return "App Launch"
        case .screenView:
            return "Screen View"
        case .buttonTap:
            return "Button Tap"
        case .textInput:
            return "Text Input"
        case .flowStart:
            return "Flow Start"
        case .flowComplete:
            return "Flow Complete"
        case .crisisReport:
            return "Crisis Report"
        case .emergencyCall:
            return "Emergency Call"
        case .emergencyAction:
            return "Emergency Action"
        case .resourceAccess:
            return "Resource Access"
        case .settingsChange:
            return "Settings Change"
        case .appClose:
            return "App Close"
        }
    }
}

struct CrisisEvent: Identifiable, Codable {
    let id: String
    let crisisId: String
    let type: CrisisEventType
    let timestamp: Date
    let severity: CrisisSeverity
    let outcome: CrisisOutcome?
    let duration: TimeInterval?
    let actions: [CrisisAction]
    
    init(
        id: String = UUID().uuidString,
        crisisId: String,
        type: CrisisEventType,
        timestamp: Date = Date(),
        severity: CrisisSeverity,
        outcome: CrisisOutcome? = nil,
        duration: TimeInterval? = nil,
        actions: [CrisisAction] = []
    ) {
        self.id = id
        self.crisisId = crisisId
        self.type = type
        self.timestamp = timestamp
        self.severity = severity
        self.outcome = outcome
        self.duration = duration
        self.actions = actions
    }
}

enum CrisisEventType: String, Codable, CaseIterable {
    case detected = "detected"
    case reported = "reported"
    case escalated = "escalated"
    case resolved = "resolved"
    case abandoned = "abandoned"
    
    var displayName: String {
        switch self {
        case .detected:
            return "Detected"
        case .reported:
            return "Reported"
        case .escalated:
            return "Escalated"
        case .resolved:
            return "Resolved"
        case .abandoned:
            return "Abandoned"
        }
    }
}

struct SessionSettings: Codable {
    let enableAnalytics: Bool
    let enableLocationTracking: Bool
    let enableNotifications: Bool
    let privacyLevel: PrivacyLevel
    let accessibilitySettings: AccessibilitySettings
    let language: String
    let timeZone: String
    
    init(
        enableAnalytics: Bool = true,
        enableLocationTracking: Bool = false,
        enableNotifications: Bool = true,
        privacyLevel: PrivacyLevel = .standard,
        accessibilitySettings: AccessibilitySettings = AccessibilitySettings(enableVoiceOver: false, enableLargeText: false, enableHighContrast: false, enableReducedMotion: false),
        language: String = Locale.current.language.languageCode?.identifier ?? "en",
        timeZone: String = TimeZone.current.identifier
    ) {
        self.enableAnalytics = enableAnalytics
        self.enableLocationTracking = enableLocationTracking
        self.enableNotifications = enableNotifications
        self.privacyLevel = privacyLevel
        self.accessibilitySettings = accessibilitySettings
        self.language = language
        self.timeZone = timeZone
    }
}

enum PrivacyLevel: String, Codable, CaseIterable {
    case minimal = "minimal"
    case standard = "standard"
    case enhanced = "enhanced"
    case maximum = "maximum"
    
    var displayName: String {
        switch self {
        case .minimal:
            return "Minimal"
        case .standard:
            return "Standard"
        case .enhanced:
            return "Enhanced"
        case .maximum:
            return "Maximum"
        }
    }
    
    var description: String {
        switch self {
        case .minimal:
            return "Only essential data is collected"
        case .standard:
            return "Standard data collection for app functionality"
        case .enhanced:
            return "Enhanced data collection for better crisis detection"
        case .maximum:
            return "Maximum data collection for comprehensive support"
        }
    }
}

struct SessionMetadata: Codable {
    let isFirstSession: Bool
    let totalSessions: Int
    let lastSessionDate: Date?
    let deviceFingerprint: String?
    let networkType: NetworkType?
    let batteryLevel: Double?
    let storageAvailable: Int64?
    let customFields: [String: String]
    
    init(
        isFirstSession: Bool = true,
        totalSessions: Int = 1,
        lastSessionDate: Date? = nil,
        deviceFingerprint: String? = nil,
        networkType: NetworkType? = nil,
        batteryLevel: Double? = nil,
        storageAvailable: Int64? = nil,
        customFields: [String: String] = [:]
    ) {
        self.isFirstSession = isFirstSession
        self.totalSessions = totalSessions
        self.lastSessionDate = lastSessionDate
        self.deviceFingerprint = deviceFingerprint
        self.networkType = networkType
        self.batteryLevel = batteryLevel
        self.storageAvailable = storageAvailable
        self.customFields = customFields
    }
}

enum NetworkType: String, Codable, CaseIterable {
    case wifi = "wifi"
    case cellular = "cellular"
    case ethernet = "ethernet"
    case unknown = "unknown"
    
    var displayName: String {
        switch self {
        case .wifi:
            return "Wi-Fi"
        case .cellular:
            return "Cellular"
        case .ethernet:
            return "Ethernet"
        case .unknown:
            return "Unknown"
        }
    }
}

// MARK: - Session Analytics

extension UserSession {
    /// Calculates session duration
    var calculatedDuration: TimeInterval {
        if let endTime = endTime {
            return endTime.timeIntervalSince(startTime)
        }
        return Date().timeIntervalSince(startTime)
    }
    
    /// Gets the most active screen during the session
    var mostActiveScreen: String? {
        let screenInteractions = interactions.filter { $0.type == .screenView }
        let screenCounts = Dictionary(grouping: screenInteractions) { $0.screen ?? "unknown" }
            .mapValues { $0.count }
        
        return screenCounts.max { $0.value < $1.value }?.key
    }
    
    /// Gets the total number of crisis events
    var totalCrisisEvents: Int {
        return crisisEvents.count
    }
    
    /// Gets the most severe crisis event
    var mostSevereCrisis: CrisisEvent? {
        return crisisEvents.max { $0.severity.rawValue < $1.severity.rawValue }
    }
    
    /// Checks if session had any emergency calls
    var hadEmergencyCalls: Bool {
        return interactions.contains { $0.type == .emergencyCall }
    }
    
    /// Gets session engagement score
    var engagementScore: Double {
        let totalInteractions = interactions.count
        let sessionDuration = calculatedDuration
        
        if sessionDuration == 0 {
            return 0
        }
        
        // Calculate interactions per minute
        let interactionsPerMinute = Double(totalInteractions) / (sessionDuration / 60)
        
        // Normalize to 0-1 scale
        return min(interactionsPerMinute / 10.0, 1.0)
    }
}

// MARK: - Session Builder

class UserSessionBuilder {
    private var session: UserSession
    
    init() {
        self.session = UserSession()
    }
    
    func withUserId(_ userId: String?) -> UserSessionBuilder {
        session = UserSession(
            id: session.id,
            userId: userId,
            startTime: session.startTime,
            endTime: session.endTime,
            duration: session.duration,
            appVersion: session.appVersion,
            deviceInfo: session.deviceInfo,
            location: session.location,
            interactions: session.interactions,
            crisisEvents: session.crisisEvents,
            settings: session.settings,
            metadata: session.metadata
        )
        return self
    }
    
    func withLocation(_ location: CLLocationCoordinate2D?) -> UserSessionBuilder {
        session = UserSession(
            id: session.id,
            userId: session.userId,
            startTime: session.startTime,
            endTime: session.endTime,
            duration: session.duration,
            appVersion: session.appVersion,
            deviceInfo: session.deviceInfo,
            location: location,
            interactions: session.interactions,
            crisisEvents: session.crisisEvents,
            settings: session.settings,
            metadata: session.metadata
        )
        return self
    }
    
    func addInteraction(_ interaction: UserInteraction) -> UserSessionBuilder {
        var interactions = session.interactions
        interactions.append(interaction)
        
        session = UserSession(
            id: session.id,
            userId: session.userId,
            startTime: session.startTime,
            endTime: session.endTime,
            duration: session.duration,
            appVersion: session.appVersion,
            deviceInfo: session.deviceInfo,
            location: session.location,
            interactions: interactions,
            crisisEvents: session.crisisEvents,
            settings: session.settings,
            metadata: session.metadata
        )
        return self
    }
    
    func addCrisisEvent(_ crisisEvent: CrisisEvent) -> UserSessionBuilder {
        var crisisEvents = session.crisisEvents
        crisisEvents.append(crisisEvent)
        
        session = UserSession(
            id: session.id,
            userId: session.userId,
            startTime: session.startTime,
            endTime: session.endTime,
            duration: session.duration,
            appVersion: session.appVersion,
            deviceInfo: session.deviceInfo,
            location: session.location,
            interactions: session.interactions,
            crisisEvents: crisisEvents,
            settings: session.settings,
            metadata: session.metadata
        )
        return self
    }
    
    func endSession() -> UserSessionBuilder {
        let endTime = Date()
        let duration = endTime.timeIntervalSince(session.startTime)
        
        session = UserSession(
            id: session.id,
            userId: session.userId,
            startTime: session.startTime,
            endTime: endTime,
            duration: duration,
            appVersion: session.appVersion,
            deviceInfo: session.deviceInfo,
            location: session.location,
            interactions: session.interactions,
            crisisEvents: session.crisisEvents,
            settings: session.settings,
            metadata: session.metadata
        )
        return self
    }
    
    func build() -> UserSession {
        return session
    }
} 