import Foundation
import CoreLocation
import SwiftUI

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

enum CrisisType: String, Codable, CaseIterable, Identifiable {
    case suicide = "suicide"
    case domesticViolence = "domestic_violence"
    case medicalEmergency = "medical_emergency"
    case mentalHealth = "mental_health"
    case substanceAbuse = "substance_abuse"
    case naturalDisaster = "natural_disaster"
    case violence = "violence"
    case abuse = "abuse"
    case harassment = "harassment"
    case panicAttack = "panic_attack"
    case other = "other"
    
    var id: String { rawValue }
    
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
        case .panicAttack:
            return "Panic Attack"
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
        case .mentalHealth, .substanceAbuse, .panicAttack:
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
        case .panicAttack:
            return "988"
        case .other:
            return "911"
        }
    }
    
    var name: String {
        return displayName
    }
    
    var description: String {
        switch self {
        case .suicide:
            return "You're not alone. Let's get you help right now."
        case .domesticViolence:
            return "Your safety is the most important thing. We'll help you get to safety."
        case .medicalEmergency:
            return "Medical help is available. Let's get you the care you need."
        case .mentalHealth:
            return "Your mental health matters. Let's find the right support for you."
        case .substanceAbuse:
            return "Recovery is possible. Let's connect you with the right resources."
        case .naturalDisaster:
            return "Stay safe and follow emergency protocols. Help is available."
        case .violence:
            return "Your safety comes first. Let's get you to a safe place."
        case .abuse:
            return "You deserve to be safe. Let's get you the help you need."
        case .harassment:
            return "You have rights. Let's help you address this situation."
        case .panicAttack:
            return "This will pass. Let's help you through this moment."
        case .other:
            return "Help is available. Let's figure out what you need."
        }
    }
    
    var icon: String {
        switch self {
        case .suicide:
            return "heart.fill"
        case .domesticViolence:
            return "house.fill"
        case .medicalEmergency:
            return "cross.fill"
        case .mentalHealth:
            return "brain.head.profile"
        case .substanceAbuse:
            return "pills.fill"
        case .naturalDisaster:
            return "tornado"
        case .violence:
            return "exclamationmark.shield.fill"
        case .abuse:
            return "person.fill.questionmark"
        case .harassment:
            return "message.fill"
        case .panicAttack:
            return "lungs.fill"
        case .other:
            return "exclamationmark.triangle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .suicide, .medicalEmergency:
            return .red
        case .domesticViolence, .violence:
            return .orange
        case .mentalHealth, .panicAttack:
            return .blue
        case .substanceAbuse:
            return .purple
        case .abuse, .harassment:
            return .yellow
        case .naturalDisaster:
            return .gray
        case .other:
            return .secondary
        }
    }
    
    var steps: [String] {
        switch self {
        case .panicAttack:
            return [
                "Find a comfortable position and sit down",
                "Take slow, deep breaths - inhale for 4 counts, hold for 4, exhale for 4",
                "Focus on your breathing and count each breath",
                "Name 5 things you can see, 4 things you can touch, 3 things you can hear",
                "Remind yourself that this will pass - panic attacks typically peak within 10 minutes",
                "If symptoms persist, call 988 or your emergency contact"
            ]
        case .suicide:
            return [
                "You are not alone - help is available 24/7",
                "Call 988 immediately - the National Suicide Prevention Lifeline",
                "Text HOME to 741741 for Crisis Text Line",
                "If you're in immediate danger, call 911",
                "Reach out to a trusted friend, family member, or counselor",
                "Remember: This feeling is temporary and you matter"
            ]
        case .domesticViolence:
            return [
                "Your safety is the most important thing",
                "If you're in immediate danger, call 911",
                "Call the National Domestic Violence Hotline: 800-799-7233",
                "Find a safe place to go - a friend's house, family member, or shelter",
                "Pack essential items if you need to leave quickly",
                "Document any injuries or incidents"
            ]
        default:
            return [
                "Stay calm and assess the situation",
                "Call the appropriate emergency number",
                "Follow any specific instructions given",
                "Get to a safe location if needed",
                "Contact a trusted person for support",
                "Remember that help is available"
            ]
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