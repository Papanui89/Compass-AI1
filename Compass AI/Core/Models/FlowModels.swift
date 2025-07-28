import Foundation
import CoreLocation
import SwiftUI
import UIKit

/// Models for flow-related data structures
struct FlowModels {
    // This file contains shared flow-related models used across the app
}

/// Represents a complete flow data structure
struct FlowData: Codable {
    let id: String
    let name: String
    let nodes: [String: FlowNode]
}

/// Represents a flow action that can be executed
struct FlowActionData: Codable {
    let type: String
    let data: [String: String]
    
    init(type: String, data: [String: String] = [:]) {
        self.type = type
        self.data = data
    }
}

/// Represents a complete flow configuration
struct FlowConfiguration: Codable {
    let id: String
    let name: String
    let version: String
    let description: String
    let category: FlowCategory
    let difficulty: FlowDifficulty
    let estimatedDuration: TimeInterval
    let tags: [String]
    let requirements: FlowRequirements
    let settings: FlowSettings
    let metadata: FlowMetadata
    
    init(
        id: String = UUID().uuidString,
        name: String,
        version: String = "1.0",
        description: String,
        category: FlowCategory,
        difficulty: FlowDifficulty = .medium,
        estimatedDuration: TimeInterval = 300, // 5 minutes default
        tags: [String] = [],
        requirements: FlowRequirements = FlowRequirements(),
        settings: FlowSettings = FlowSettings(),
        metadata: FlowMetadata = FlowMetadata()
    ) {
        self.id = id
        self.name = name
        self.version = version
        self.description = description
        self.category = category
        self.difficulty = difficulty
        self.estimatedDuration = estimatedDuration
        self.tags = tags
        self.requirements = requirements
        self.settings = settings
        self.metadata = metadata
    }
}

enum FlowCategory: String, Codable, CaseIterable {
    case emergency = "emergency"
    case support = "support"
    case information = "information"
    case assessment = "assessment"
    case referral = "referral"
    case custom = "custom"
    
    var displayName: String {
        switch self {
        case .emergency:
            return "Emergency"
        case .support:
            return "Support"
        case .information:
            return "Information"
        case .assessment:
            return "Assessment"
        case .referral:
            return "Referral"
        case .custom:
            return "Custom"
        }
    }
    
    var icon: String {
        switch self {
        case .emergency:
            return "exclamationmark.triangle.fill"
        case .support:
            return "heart.fill"
        case .information:
            return "info.circle.fill"
        case .assessment:
            return "clipboard.fill"
        case .referral:
            return "arrow.right.circle.fill"
        case .custom:
            return "gear"
        }
    }
}

struct FlowRequirements: Codable {
    let requiresLocation: Bool
    let requiresContacts: Bool
    let requiresInternet: Bool
    let requiresPermissions: [PermissionType]
    let minimumAge: Int?
    let deviceCapabilities: [DeviceCapability]
    
    init(
        requiresLocation: Bool = false,
        requiresContacts: Bool = false,
        requiresInternet: Bool = false,
        requiresPermissions: [PermissionType] = [],
        minimumAge: Int? = nil,
        deviceCapabilities: [DeviceCapability] = []
    ) {
        self.requiresLocation = requiresLocation
        self.requiresContacts = requiresContacts
        self.requiresInternet = requiresInternet
        self.requiresPermissions = requiresPermissions
        self.minimumAge = minimumAge
        self.deviceCapabilities = deviceCapabilities
    }
}

enum PermissionType: String, Codable, CaseIterable {
    case location = "location"
    case contacts = "contacts"
    case camera = "camera"
    case microphone = "microphone"
    case notifications = "notifications"
    case health = "health"
    
    var displayName: String {
        switch self {
        case .location:
            return "Location Access"
        case .contacts:
            return "Contacts Access"
        case .camera:
            return "Camera Access"
        case .microphone:
            return "Microphone Access"
        case .notifications:
            return "Notifications"
        case .health:
            return "Health Data"
        }
    }
}

enum DeviceCapability: String, Codable, CaseIterable {
    case hapticFeedback = "haptic_feedback"
    case voiceRecognition = "voice_recognition"
    case textToSpeech = "text_to_speech"
    case camera = "camera"
    case microphone = "microphone"
    case gps = "gps"
    case internet = "internet"
    
    var displayName: String {
        switch self {
        case .hapticFeedback:
            return "Haptic Feedback"
        case .voiceRecognition:
            return "Voice Recognition"
        case .textToSpeech:
            return "Text to Speech"
        case .camera:
            return "Camera"
        case .microphone:
            return "Microphone"
        case .gps:
            return "GPS"
        case .internet:
            return "Internet Connection"
        }
    }
}

struct FlowSettings: Codable {
    let allowBacktracking: Bool
    let allowSkipping: Bool
    let requireConfirmation: Bool
    let autoSave: Bool
    let enableAnalytics: Bool
    let timeoutDuration: TimeInterval?
    let retryLimit: Int?
    
    init(
        allowBacktracking: Bool = true,
        allowSkipping: Bool = false,
        requireConfirmation: Bool = true,
        autoSave: Bool = true,
        enableAnalytics: Bool = true,
        timeoutDuration: TimeInterval? = nil,
        retryLimit: Int? = nil
    ) {
        self.allowBacktracking = allowBacktracking
        self.allowSkipping = allowSkipping
        self.requireConfirmation = requireConfirmation
        self.autoSave = autoSave
        self.enableAnalytics = enableAnalytics
        self.timeoutDuration = timeoutDuration
        self.retryLimit = retryLimit
    }
}

struct FlowMetadata: Codable {
    let author: String?
    let createdDate: Date
    let lastModified: Date
    let versionHistory: [VersionInfo]
    let usageStats: UsageStatistics?
    let ratings: [FlowRating]
    let customFields: [String: String]
    
    init(
        author: String? = nil,
        createdDate: Date = Date(),
        lastModified: Date = Date(),
        versionHistory: [VersionInfo] = [],
        usageStats: UsageStatistics? = nil,
        ratings: [FlowRating] = [],
        customFields: [String: String] = [:]
    ) {
        self.author = author
        self.createdDate = createdDate
        self.lastModified = lastModified
        self.versionHistory = versionHistory
        self.usageStats = usageStats
        self.ratings = ratings
        self.customFields = customFields
    }
}

struct VersionInfo: Codable {
    let version: String
    let date: Date
    let changes: [String]
    let author: String?
}

struct UsageStatistics: Codable {
    let totalRuns: Int
    let averageCompletionTime: TimeInterval
    let completionRate: Double
    let averageRating: Double
    let lastUsed: Date?
}

struct FlowRating: Codable {
    let userId: String?
    let rating: Int // 1-5 stars
    let comment: String?
    let date: Date
    let helpful: Bool?
}

/// Represents a flow execution session
struct FlowExecution: Codable {
    let id: String
    let flowId: String
    let userId: String?
    let startTime: Date
    let endTime: Date?
    let status: ExecutionStatus
    let currentNode: String?
    let progress: Double
    let actions: [ExecutionAction]
    let errors: [ExecutionError]
    let metadata: ExecutionMetadata
    
    init(
        id: String = UUID().uuidString,
        flowId: String,
        userId: String? = nil,
        startTime: Date = Date(),
        endTime: Date? = nil,
        status: ExecutionStatus = .running,
        currentNode: String? = nil,
        progress: Double = 0.0,
        actions: [ExecutionAction] = [],
        errors: [ExecutionError] = [],
        metadata: ExecutionMetadata = ExecutionMetadata()
    ) {
        self.id = id
        self.flowId = flowId
        self.userId = userId
        self.startTime = startTime
        self.endTime = endTime
        self.status = status
        self.currentNode = currentNode
        self.progress = progress
        self.actions = actions
        self.errors = errors
        self.metadata = metadata
    }
}

enum ExecutionStatus: String, Codable, CaseIterable {
    case notStarted = "not_started"
    case running = "running"
    case paused = "paused"
    case completed = "completed"
    case failed = "failed"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .notStarted:
            return "Not Started"
        case .running:
            return "Running"
        case .paused:
            return "Paused"
        case .completed:
            return "Completed"
        case .failed:
            return "Failed"
        case .cancelled:
            return "Cancelled"
        }
    }
}

struct ExecutionAction: Codable {
    let id: String
    let nodeId: String
    let actionType: ActionType
    let timestamp: Date
    let success: Bool
    let result: String?
    let duration: TimeInterval?
    
    init(
        id: String = UUID().uuidString,
        nodeId: String,
        actionType: ActionType,
        timestamp: Date = Date(),
        success: Bool,
        result: String? = nil,
        duration: TimeInterval? = nil
    ) {
        self.id = id
        self.nodeId = nodeId
        self.actionType = actionType
        self.timestamp = timestamp
        self.success = success
        self.result = result
        self.duration = duration
    }
}

struct ExecutionError: Codable {
    let id: String
    let nodeId: String?
    let errorType: ErrorType
    let message: String
    let timestamp: Date
    let recoverable: Bool
    let stackTrace: String?
    
    init(
        id: String = UUID().uuidString,
        nodeId: String? = nil,
        errorType: ErrorType,
        message: String,
        timestamp: Date = Date(),
        recoverable: Bool = true,
        stackTrace: String? = nil
    ) {
        self.id = id
        self.nodeId = nodeId
        self.errorType = errorType
        self.message = message
        self.timestamp = timestamp
        self.recoverable = recoverable
        self.stackTrace = stackTrace
    }
}

enum ErrorType: String, Codable, CaseIterable {
    case validation = "validation"
    case network = "network"
    case permission = "permission"
    case timeout = "timeout"
    case resource = "resource"
    case unknown = "unknown"
    
    var displayName: String {
        switch self {
        case .validation:
            return "Validation Error"
        case .network:
            return "Network Error"
        case .permission:
            return "Permission Error"
        case .timeout:
            return "Timeout Error"
        case .resource:
            return "Resource Error"
        case .unknown:
            return "Unknown Error"
        }
    }
}

struct ExecutionMetadata: Codable {
    let deviceInfo: DeviceInfo
    let appVersion: String
    let networkType: NetworkType?
    let batteryLevel: Double?
    let location: CLLocationCoordinate2D?
    let customFields: [String: String]
    
    init(
        deviceInfo: DeviceInfo = DeviceInfo(model: UIDevice.current.model, systemVersion: UIDevice.current.systemVersion, appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"),
        appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
        networkType: NetworkType? = nil,
        batteryLevel: Double? = nil,
        location: CLLocationCoordinate2D? = nil,
        customFields: [String: String] = [:]
    ) {
        self.deviceInfo = deviceInfo
        self.appVersion = appVersion
        self.networkType = networkType
        self.batteryLevel = batteryLevel
        self.location = location
        self.customFields = customFields
    }
}

/// Represents a flow template for creating new flows
struct FlowTemplate: Codable {
    let id: String
    let name: String
    let description: String
    let category: FlowCategory
    let template: FlowTemplateData
    let variables: [TemplateVariable]
    let instructions: String?
    let tags: [String]
    
    init(
        id: String = UUID().uuidString,
        name: String,
        description: String,
        category: FlowCategory,
        template: FlowTemplateData,
        variables: [TemplateVariable] = [],
        instructions: String? = nil,
        tags: [String] = []
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.template = template
        self.variables = variables
        self.instructions = instructions
        self.tags = tags
    }
}

struct FlowTemplateData: Codable {
    let nodes: [FlowNode]
    let connections: [NodeConnection]
    let settings: FlowSettings
    let requirements: FlowRequirements
}

struct NodeConnection: Codable {
    let fromNodeId: String
    let toNodeId: String
    let condition: String?
    let label: String?
}

struct TemplateVariable: Codable {
    let name: String
    let type: VariableType
    let defaultValue: String?
    let required: Bool
    let description: String?
    
    init(
        name: String,
        type: VariableType,
        defaultValue: String? = nil,
        required: Bool = false,
        description: String? = nil
    ) {
        self.name = name
        self.type = type
        self.defaultValue = defaultValue
        self.required = required
        self.description = description
    }
}

enum VariableType: String, Codable, CaseIterable {
    case string = "string"
    case number = "number"
    case boolean = "boolean"
    case date = "date"
    case phone = "phone"
    case email = "email"
    case url = "url"
    
    var displayName: String {
        switch self {
        case .string:
            return "Text"
        case .number:
            return "Number"
        case .boolean:
            return "Yes/No"
        case .date:
            return "Date"
        case .phone:
            return "Phone Number"
        case .email:
            return "Email"
        case .url:
            return "URL"
        }
    }
}

// MARK: - Conversational Flow Models

/// Represents a conversational flow node
struct ConversationalNode: Codable {
    let id: String
    let type: String
    let messages: [String]
    let delay: Double?
    let options: [ConversationOption]?
    let action: String?
    let nextNode: String?
    
    init(
        id: String,
        type: String,
        messages: [String],
        delay: Double? = nil,
        options: [ConversationOption]? = nil,
        action: String? = nil,
        nextNode: String? = nil
    ) {
        self.id = id
        self.type = type
        self.messages = messages
        self.delay = delay
        self.options = options
        self.action = action
        self.nextNode = nextNode
    }
}

/// Represents a conversation option/choice
struct ConversationOption: Codable {
    let text: String
    let nextNode: String
    
    init(text: String, nextNode: String) {
        self.text = text
        self.nextNode = nextNode
    }
}

/// Represents metadata for conversational flows
struct ConversationalFlowMetadata: Codable {
    let author: String?
    let tags: [String]
    let difficulty: String
    let estimatedDuration: Int
    let emergencyLevel: String
    let requiresLocation: Bool
    let requiresContacts: Bool
    
    init(
        author: String? = nil,
        tags: [String] = [],
        difficulty: String = "easy",
        estimatedDuration: Int = 180,
        emergencyLevel: String = "medium",
        requiresLocation: Bool = false,
        requiresContacts: Bool = false
    ) {
        self.author = author
        self.tags = tags
        self.difficulty = difficulty
        self.estimatedDuration = estimatedDuration
        self.emergencyLevel = emergencyLevel
        self.requiresLocation = requiresLocation
        self.requiresContacts = requiresContacts
    }
}

/// Represents a conversational flow
struct ConversationalFlow: Codable {
    let id: String
    let type: String
    let title: String
    let description: String
    let version: String
    let startNode: String
    let nodes: [ConversationalNode]
    let metadata: ConversationalFlowMetadata
    let createdAt: Date
    let updatedAt: Date
    
    init(
        id: String,
        type: String,
        title: String,
        description: String,
        version: String,
        startNode: String,
        nodes: [ConversationalNode],
        metadata: ConversationalFlowMetadata,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.description = description
        self.version = version
        self.startNode = startNode
        self.nodes = nodes
        self.metadata = metadata
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Represents a conversation message type
enum ConversationMessageType: String, Codable {
    case text
    case action
    case breathing
    case grounding
    case contacts
} 