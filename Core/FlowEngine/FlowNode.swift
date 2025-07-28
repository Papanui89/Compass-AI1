import Foundation
import SwiftUI

/// Represents a single step in a crisis response flow
class FlowNode: Identifiable, Codable {
    let id: String
    let type: NodeType
    let title: String
    let content: String
    let actions: [FlowAction]
    let conditions: [FlowCondition]?
    let nextNodes: [String: String] // condition -> nextNodeId
    
    init(id: String, type: NodeType, title: String, content: String, actions: [FlowAction], conditions: [FlowCondition]? = nil, nextNodes: [String: String] = [:]) {
        self.id = id
        self.type = type
        self.title = title
        self.content = content
        self.actions = actions
        self.conditions = conditions
        self.nextNodes = nextNodes
    }
    
    func execute() async throws -> FlowResult {
        // Execute all actions for this node
        var results: [FlowActionResult] = []
        
        for action in actions {
            let result = try await action.execute()
            results.append(result)
        }
        
        return FlowResult(nodeId: id, actionResults: results, timestamp: Date())
    }
    
    func getNextNode(based result: FlowResult) -> FlowNode? {
        // Determine next node based on conditions and results
        guard let conditions = conditions else {
            return nil
        }
        
        for condition in conditions {
            if condition.evaluate(with: result) {
                if let nextNodeId = nextNodes[condition.id] {
                    // Return the next node (this would need to be looked up from the flow)
                    return nil // Placeholder - would need flow context
                }
            }
        }
        
        return nil
    }
}

enum NodeType: String, Codable, CaseIterable {
    case question = "question"
    case instruction = "instruction"
    case action = "action"
    case decision = "decision"
    case emergency = "emergency"
    case resource = "resource"
}

struct FlowAction: Identifiable, Codable {
    let id: String
    let type: ActionType
    let title: String
    let parameters: [String: String]
    
    func execute() async throws -> FlowActionResult {
        switch type {
        case .call:
            return try await executeCall()
        case .text:
            return try await executeText()
        case .location:
            return try await executeLocation()
        case .haptic:
            return try await executeHaptic()
        case .audio:
            return try await executeAudio()
        case .notification:
            return try await executeNotification()
        }
    }
    
    private func executeCall() async throws -> FlowActionResult {
        // Implementation for making emergency calls
        return FlowActionResult(actionId: id, success: true, data: [:])
    }
    
    private func executeText() async throws -> FlowActionResult {
        // Implementation for sending text messages
        return FlowActionResult(actionId: id, success: true, data: [:])
    }
    
    private func executeLocation() async throws -> FlowActionResult {
        // Implementation for location services
        return FlowActionResult(actionId: id, success: true, data: [:])
    }
    
    private func executeHaptic() async throws -> FlowActionResult {
        // Implementation for haptic feedback
        return FlowActionResult(actionId: id, success: true, data: [:])
    }
    
    private func executeAudio() async throws -> FlowActionResult {
        // Implementation for audio playback
        return FlowActionResult(actionId: id, success: true, data: [:])
    }
    
    private func executeNotification() async throws -> FlowActionResult {
        // Implementation for notifications
        return FlowActionResult(actionId: id, success: true, data: [:])
    }
}

enum ActionType: String, Codable, CaseIterable {
    case call = "call"
    case text = "text"
    case location = "location"
    case haptic = "haptic"
    case audio = "audio"
    case notification = "notification"
}

struct FlowCondition: Identifiable, Codable {
    let id: String
    let type: ConditionType
    let parameters: [String: String]
    
    func evaluate(with result: FlowResult) -> Bool {
        switch type {
        case .userResponse:
            return evaluateUserResponse(result)
        case .timeElapsed:
            return evaluateTimeElapsed(result)
        case .locationBased:
            return evaluateLocationBased(result)
        case .emergencyLevel:
            return evaluateEmergencyLevel(result)
        }
    }
    
    private func evaluateUserResponse(_ result: FlowResult) -> Bool {
        // Implementation for user response evaluation
        return true
    }
    
    private func evaluateTimeElapsed(_ result: FlowResult) -> Bool {
        // Implementation for time-based evaluation
        return true
    }
    
    private func evaluateLocationBased(_ result: FlowResult) -> Bool {
        // Implementation for location-based evaluation
        return true
    }
    
    private func evaluateEmergencyLevel(_ result: FlowResult) -> Bool {
        // Implementation for emergency level evaluation
        return true
    }
}

enum ConditionType: String, Codable, CaseIterable {
    case userResponse = "user_response"
    case timeElapsed = "time_elapsed"
    case locationBased = "location_based"
    case emergencyLevel = "emergency_level"
}

struct FlowResult {
    let nodeId: String
    let actionResults: [FlowActionResult]
    let timestamp: Date
}

struct FlowActionResult {
    let actionId: String
    let success: Bool
    let data: [String: Any]
} 