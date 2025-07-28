import Foundation
import CoreLocation

/// Models for emergency content and resources
struct EmergencyContent: Identifiable, Codable {
    let id: String
    let type: EmergencyContentType
    let title: String
    let content: String
    let resources: [EmergencyResource]
    let lastUpdated: Date
    let metadata: ContentMetadata
    
    init(
        id: String = UUID().uuidString,
        type: EmergencyContentType,
        title: String,
        content: String,
        resources: [EmergencyResource] = [],
        lastUpdated: Date = Date(),
        metadata: ContentMetadata = ContentMetadata()
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.content = content
        self.resources = resources
        self.lastUpdated = lastUpdated
        self.metadata = metadata
    }
}

enum EmergencyContentType: String, Codable, CaseIterable {
    case suicidePrevention = "suicide_prevention"
    case domesticViolence = "domestic_violence"
    case medicalEmergency = "medical_emergency"
    case mentalHealth = "mental_health"
    case substanceAbuse = "substance_abuse"
    case naturalDisaster = "natural_disaster"
    case violence = "violence"
    case abuse = "abuse"
    case harassment = "harassment"
    case legalRights = "legal_rights"
    case safetyPlanning = "safety_planning"
    case crisisIntervention = "crisis_intervention"
    
    var displayName: String {
        switch self {
        case .suicidePrevention:
            return "Suicide Prevention"
        case .domesticViolence:
            return "Domestic Violence"
        case .medicalEmergency:
            return "Medical Emergency"
        case .mentalHealth:
            return "Mental Health"
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
        case .legalRights:
            return "Legal Rights"
        case .safetyPlanning:
            return "Safety Planning"
        case .crisisIntervention:
            return "Crisis Intervention"
        }
    }
    
    var priority: ContentPriority {
        switch self {
        case .suicidePrevention, .medicalEmergency:
            return .critical
        case .domesticViolence, .violence, .abuse:
            return .high
        case .mentalHealth, .substanceAbuse:
            return .medium
        case .harassment, .legalRights, .safetyPlanning:
            return .medium
        case .naturalDisaster, .crisisIntervention:
            return .high
        }
    }
    
    var icon: String {
        switch self {
        case .suicidePrevention:
            return "heart.slash"
        case .domesticViolence:
            return "house.slash"
        case .medicalEmergency:
            return "cross.case"
        case .mentalHealth:
            return "brain.head.profile"
        case .substanceAbuse:
            return "pills"
        case .naturalDisaster:
            return "tornado"
        case .violence:
            return "exclamationmark.shield"
        case .abuse:
            return "person.slash"
        case .harassment:
            return "message.slash"
        case .legalRights:
            return "doc.text"
        case .safetyPlanning:
            return "checklist"
        case .crisisIntervention:
            return "phone.arrow.up.right"
        }
    }
}

enum ContentPriority: String, Codable, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
    
    var displayName: String {
        switch self {
        case .low:
            return "Low Priority"
        case .medium:
            return "Medium Priority"
        case .high:
            return "High Priority"
        case .critical:
            return "Critical Priority"
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
}

struct EmergencyResource: Identifiable, Codable {
    let id: String
    let name: String
    let type: ResourceType
    let url: String?
    let phoneNumber: String?
    let description: String
    let availability: ResourceAvailability
    let location: ResourceLocation?
    let languages: [String]
    let metadata: ResourceMetadata
    
    init(
        id: String = UUID().uuidString,
        name: String,
        type: ResourceType,
        url: String? = nil,
        phoneNumber: String? = nil,
        description: String,
        availability: ResourceAvailability = .available,
        location: ResourceLocation? = nil,
        languages: [String] = ["en"],
        metadata: ResourceMetadata = ResourceMetadata()
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.url = url
        self.phoneNumber = phoneNumber
        self.description = description
        self.availability = availability
        self.location = location
        self.languages = languages
        self.metadata = metadata
    }
}

enum ResourceType: String, Codable, CaseIterable {
    case website = "website"
    case phone = "phone"
    case text = "text"
    case chat = "chat"
    case app = "app"
    case email = "email"
    case socialMedia = "social_media"
    case inPerson = "in_person"
    case video = "video"
    case document = "document"
    
    var displayName: String {
        switch self {
        case .website:
            return "Website"
        case .phone:
            return "Phone"
        case .text:
            return "Text"
        case .chat:
            return "Chat"
        case .app:
            return "App"
        case .email:
            return "Email"
        case .socialMedia:
            return "Social Media"
        case .inPerson:
            return "In Person"
        case .video:
            return "Video"
        case .document:
            return "Document"
        }
    }
    
    var icon: String {
        switch self {
        case .website:
            return "globe"
        case .phone:
            return "phone"
        case .text:
            return "message"
        case .chat:
            return "bubble.left.and.bubble.right"
        case .app:
            return "app.badge"
        case .email:
            return "envelope"
        case .socialMedia:
            return "person.2"
        case .inPerson:
            return "person.crop.circle"
        case .video:
            return "video"
        case .document:
            return "doc.text"
        }
    }
}

enum ResourceAvailability: String, Codable, CaseIterable {
    case available = "available"
    case limited = "limited"
    case unavailable = "unavailable"
    case emergency = "emergency"
    
    var displayName: String {
        switch self {
        case .available:
            return "Available"
        case .limited:
            return "Limited Hours"
        case .unavailable:
            return "Unavailable"
        case .emergency:
            return "Emergency Only"
        }
    }
    
    var color: String {
        switch self {
        case .available:
            return "green"
        case .limited:
            return "yellow"
        case .unavailable:
            return "red"
        case .emergency:
            return "orange"
        }
    }
}

struct ResourceLocation: Codable {
    let name: String
    let address: String?
    let city: String?
    let state: String?
    let zipCode: String?
    let country: String?
    let coordinates: CLLocationCoordinate2D?
    let distance: Double?
    
    init(
        name: String,
        address: String? = nil,
        city: String? = nil,
        state: String? = nil,
        zipCode: String? = nil,
        country: String? = nil,
        coordinates: CLLocationCoordinate2D? = nil,
        distance: Double? = nil
    ) {
        self.name = name
        self.address = address
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.country = country
        self.coordinates = coordinates
        self.distance = distance
    }
    
    var fullAddress: String {
        var components: [String] = []
        
        if let address = address {
            components.append(address)
        }
        
        if let city = city {
            components.append(city)
        }
        
        if let state = state {
            components.append(state)
        }
        
        if let zipCode = zipCode {
            components.append(zipCode)
        }
        
        if let country = country {
            components.append(country)
        }
        
        return components.joined(separator: ", ")
    }
}

struct ResourceMetadata: Codable {
    let verified: Bool
    let lastVerified: Date?
    let rating: Double?
    let reviewCount: Int
    let tags: [String]
    let customFields: [String: String]
    
    init(
        verified: Bool = false,
        lastVerified: Date? = nil,
        rating: Double? = nil,
        reviewCount: Int = 0,
        tags: [String] = [],
        customFields: [String: String] = [:]
    ) {
        self.verified = verified
        self.lastVerified = lastVerified
        self.rating = rating
        self.reviewCount = reviewCount
        self.tags = tags
        self.customFields = customFields
    }
}

struct ContentMetadata: Codable {
    let author: String?
    let source: String?
    let lastReviewed: Date?
    let reviewFrequency: ReviewFrequency
    let targetAudience: [TargetAudience]
    let accessibility: AccessibilityInfo
    let customFields: [String: String]
    
    init(
        author: String? = nil,
        source: String? = nil,
        lastReviewed: Date? = nil,
        reviewFrequency: ReviewFrequency = .monthly,
        targetAudience: [TargetAudience] = [],
        accessibility: AccessibilityInfo = AccessibilityInfo(),
        customFields: [String: String] = [:]
    ) {
        self.author = author
        self.source = source
        self.lastReviewed = lastReviewed
        self.reviewFrequency = reviewFrequency
        self.targetAudience = targetAudience
        self.accessibility = accessibility
        self.customFields = customFields
    }
}

enum ReviewFrequency: String, Codable, CaseIterable {
    case weekly = "weekly"
    case monthly = "monthly"
    case quarterly = "quarterly"
    case annually = "annually"
    case asNeeded = "as_needed"
    
    var displayName: String {
        switch self {
        case .weekly:
            return "Weekly"
        case .monthly:
            return "Monthly"
        case .quarterly:
            return "Quarterly"
        case .annually:
            return "Annually"
        case .asNeeded:
            return "As Needed"
        }
    }
}

enum TargetAudience: String, Codable, CaseIterable {
    case general = "general"
    case youth = "youth"
    case adults = "adults"
    case seniors = "seniors"
    case lgbtq = "lgbtq"
    case veterans = "veterans"
    case immigrants = "immigrants"
    case disabled = "disabled"
    case survivors = "survivors"
    
    var displayName: String {
        switch self {
        case .general:
            return "General"
        case .youth:
            return "Youth"
        case .adults:
            return "Adults"
        case .seniors:
            return "Seniors"
        case .lgbtq:
            return "LGBTQ+"
        case .veterans:
            return "Veterans"
        case .immigrants:
            return "Immigrants"
        case .disabled:
            return "People with Disabilities"
        case .survivors:
            return "Survivors"
        }
    }
}

struct AccessibilityInfo: Codable {
    let hasAudioVersion: Bool
    let hasVideoVersion: Bool
    let hasLargeText: Bool
    let hasHighContrast: Bool
    let supportsScreenReader: Bool
    let supportsVoiceControl: Bool
    let languages: [String]
    
    init(
        hasAudioVersion: Bool = false,
        hasVideoVersion: Bool = false,
        hasLargeText: Bool = false,
        hasHighContrast: Bool = false,
        supportsScreenReader: Bool = true,
        supportsVoiceControl: Bool = false,
        languages: [String] = ["en"]
    ) {
        self.hasAudioVersion = hasAudioVersion
        self.hasVideoVersion = hasVideoVersion
        self.hasLargeText = hasLargeText
        self.hasHighContrast = hasHighContrast
        self.supportsScreenReader = supportsScreenReader
        self.supportsVoiceControl = supportsVoiceControl
        self.languages = languages
    }
}

// MARK: - Content Categories

struct ContentCategory: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let color: String
    let contentTypes: [EmergencyContentType]
    let priority: ContentPriority
    
    init(
        id: String = UUID().uuidString,
        name: String,
        description: String,
        icon: String,
        color: String,
        contentTypes: [EmergencyContentType],
        priority: ContentPriority
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.color = color
        self.contentTypes = contentTypes
        self.priority = priority
    }
}

// MARK: - Content Search

struct ContentSearchQuery: Codable {
    let query: String
    let contentTypes: [EmergencyContentType]?
    let priority: ContentPriority?
    let location: CLLocationCoordinate2D?
    let radius: Double?
    let languages: [String]?
    let tags: [String]?
    
    init(
        query: String = "",
        contentTypes: [EmergencyContentType]? = nil,
        priority: ContentPriority? = nil,
        location: CLLocationCoordinate2D? = nil,
        radius: Double? = nil,
        languages: [String]? = nil,
        tags: [String]? = nil
    ) {
        self.query = query
        self.contentTypes = contentTypes
        self.priority = priority
        self.location = location
        self.radius = radius
        self.languages = languages
        self.tags = tags
    }
}

struct ContentSearchResult: Codable {
    let content: EmergencyContent
    let relevanceScore: Double
    let matchedTerms: [String]
    let distance: Double?
    
    init(
        content: EmergencyContent,
        relevanceScore: Double,
        matchedTerms: [String] = [],
        distance: Double? = nil
    ) {
        self.content = content
        self.relevanceScore = relevanceScore
        self.matchedTerms = matchedTerms
        self.distance = distance
    }
}

