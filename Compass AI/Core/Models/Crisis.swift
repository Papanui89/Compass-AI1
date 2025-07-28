import Foundation
import CoreLocation

/// Represents a crisis situation and its associated data
struct Crisis: Identifiable, Codable {
    let id: String
    let type: CrisisType
    let severity: CrisisSeverity
    let status: CrisisStatus
    let location: CLLocationCoordinate2D?
    let timestamp: Date
    let description: String?
    let triggers: [Trigger]
    let actions: [CrisisAction]
    let contacts: [EmergencyContact]
    let metadata: CrisisMetadata
    
    init(
        id: String = UUID().uuidString,
        type: CrisisType,
        severity: CrisisSeverity,
        status: CrisisStatus = .active,
        location: CLLocationCoordinate2D? = nil,
        timestamp: Date = Date(),
        description: String? = nil,
        triggers: [Trigger] = [],
        actions: [CrisisAction] = [],
        contacts: [EmergencyContact] = [],
        metadata: CrisisMetadata = CrisisMetadata()
    ) {
        self.id = id
        self.type = type
        self.severity = severity
        self.status = status
        self.location = location
        self.timestamp = timestamp
        self.description = description
        self.triggers = triggers
        self.actions = actions
        self.contacts = contacts
        self.metadata = metadata
    }
}

enum CrisisType: String, Codable, CaseIterable {
    case suicide = "suicide"
    case domesticViolence = "domestic_violence"
    case medicalEmergency = "medical_emergency"
    case mentalHealth = "mental_health"
    case substanceAbuse = "substance_abuse"
    case naturalDisaster = "natural_disaster"
    case violence = "violence"
    case abuse = "abuse"
    case harassment = "harassment"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .suicide:
            return "Suicide Crisis"
        case .domesticViolence:
            return "Domestic Violence"
        case .medicalEmergency:
            return "Medical Emergency"
        case .mentalHealth:
            return "Mental Health Crisis"
        case .substanceAbuse:
            return "Substance Abuse"
        case .naturalDisaster:
            return "Natural Disaster"
        case .violence:
            return "Violence"
        case .abuse:
            return "Abuse"
        case .harassment:
            return "Harassment"
        case .other:
            return "Other Crisis"
        }
    }
    
    var priority: CrisisPriority {
        switch self {
        case .suicide, .medicalEmergency:
            return .immediate
        case .domesticViolence, .violence:
            return .high
        case .mentalHealth, .substanceAbuse:
            return .medium
        case .abuse, .harassment:
            return .medium
        case .naturalDisaster:
            return .high
        case .other:
            return .low
        }
    }
    
    var emergencyNumber: String {
        switch self {
        case .suicide:
            return "988" // National Suicide Prevention Lifeline
        case .domesticViolence:
            return "800-799-7233" // National Domestic Violence Hotline
        case .medicalEmergency:
            return "911"
        case .mentalHealth:
            return "988"
        case .substanceAbuse:
            return "800-662-4357" // SAMHSA National Helpline
        case .naturalDisaster:
            return "911"
        case .violence:
            return "911"
        case .abuse:
            return "800-422-4453" // Childhelp National Child Abuse Hotline
        case .harassment:
            return "911"
        case .other:
            return "911"
        }
    }
}

enum CrisisSeverity: String, Codable, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
    
    var displayName: String {
        switch self {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        case .critical:
            return "Critical"
        }
    }
    
    var color: String {
        switch self {
        case .low:
            return "green"
        case .medium:
            return "yellow"
        case .high:
            return "orange"
        case .critical:
            return "red"
        }
    }
    
    var requiresImmediateAction: Bool {
        switch self {
        case .low, .medium:
            return false
        case .high, .critical:
            return true
        }
    }
}

enum CrisisStatus: String, Codable, CaseIterable {
    case active = "active"
    case resolved = "resolved"
    case escalated = "escalated"
    case monitoring = "monitoring"
    case closed = "closed"
    
    var displayName: String {
        switch self {
        case .active:
            return "Active"
        case .resolved:
            return "Resolved"
        case .escalated:
            return "Escalated"
        case .monitoring:
            return "Monitoring"
        case .closed:
            return "Closed"
        }
    }
}

enum CrisisPriority: String, Codable, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case immediate = "immediate"
    
    var displayName: String {
        switch self {
        case .low:
            return "Low Priority"
        case .medium:
            return "Medium Priority"
        case .high:
            return "High Priority"
        case .immediate:
            return "Immediate Action Required"
        }
    }
}

struct CrisisAction: Identifiable, Codable {
    let id: String
    let type: ActionType
    let timestamp: Date
    let success: Bool
    let details: String?
    let metadata: [String: String]
    
    init(
        id: String = UUID().uuidString,
        type: ActionType,
        timestamp: Date = Date(),
        success: Bool,
        details: String? = nil,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.type = type
        self.timestamp = timestamp
        self.success = success
        self.details = details
        self.metadata = metadata
    }
}

struct CrisisMetadata: Codable {
    let source: CrisisSource
    let confidence: Double
    let aiAnalysis: AIAnalysis?
    let userNotes: String?
    let tags: [String]
    let customFields: [String: String]
    
    init(
        source: CrisisSource = .manual,
        confidence: Double = 1.0,
        aiAnalysis: AIAnalysis? = nil,
        userNotes: String? = nil,
        tags: [String] = [],
        customFields: [String: String] = [:]
    ) {
        self.source = source
        self.confidence = confidence
        self.aiAnalysis = aiAnalysis
        self.userNotes = userNotes
        self.tags = tags
        self.customFields = customFields
    }
}

enum CrisisSource: String, Codable, CaseIterable {
    case manual = "manual"
    case aiDetection = "ai_detection"
    case triggerWord = "trigger_word"
    case behaviorAnalysis = "behavior_analysis"
    case externalAlert = "external_alert"
    case userReport = "user_report"
    
    var displayName: String {
        switch self {
        case .manual:
            return "Manual Entry"
        case .aiDetection:
            return "AI Detection"
        case .triggerWord:
            return "Trigger Word Detection"
        case .behaviorAnalysis:
            return "Behavior Analysis"
        case .externalAlert:
            return "External Alert"
        case .userReport:
            return "User Report"
        }
    }
}

struct AIAnalysis: Codable {
    let riskScore: Double
    let confidence: Double
    let triggers: [Trigger]
    let sentiment: Sentiment
    let recommendations: [String]
    let modelVersion: String
    let timestamp: Date
}

// MARK: - CLLocationCoordinate2D Codable Extension

extension CLLocationCoordinate2D: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
    
    private enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
} 