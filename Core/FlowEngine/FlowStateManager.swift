import Foundation
import SwiftUI

/// Manages the state of flow execution and user progress
class FlowStateManager: ObservableObject {
    @Published var currentSession: FlowSession?
    @Published var completedNodes: Set<String> = []
    @Published var userResponses: [String: String] = [:]
    @Published var emergencyLevel: EmergencyLevel = .low
    @Published var startTime: Date?
    @Published var lastActivity: Date?
    
    private let secureStorage = SecureStorage.shared
    
    init() {
        loadSession()
    }
    
    func startSession(flowType: FlowType) {
        let session = FlowSession(
            id: UUID().uuidString,
            flowType: flowType,
            startTime: Date(),
            status: .active
        )
        
        currentSession = session
        startTime = Date()
        lastActivity = Date()
        
        saveSession()
    }
    
    func updateState(with result: FlowResult) {
        completedNodes.insert(result.nodeId)
        lastActivity = Date()
        
        // Update emergency level based on actions taken
        updateEmergencyLevel(from: result)
        
        saveSession()
    }
    
    func addUserResponse(nodeId: String, response: String) {
        userResponses[nodeId] = response
        lastActivity = Date()
        saveSession()
    }
    
    func pauseSession() {
        currentSession?.status = .paused
        saveSession()
    }
    
    func resumeSession() {
        currentSession?.status = .active
        lastActivity = Date()
        saveSession()
    }
    
    func endSession() {
        currentSession?.status = .completed
        currentSession?.endTime = Date()
        saveSession()
    }
    
    func reset() {
        currentSession = nil
        completedNodes.removeAll()
        userResponses.removeAll()
        emergencyLevel = .low
        startTime = nil
        lastActivity = nil
        
        // Clear from storage
        try? secureStorage.delete(key: "flow_session")
    }
    
    private func updateEmergencyLevel(from result: FlowResult) {
        // Analyze action results to determine emergency level
        let emergencyActions = result.actionResults.filter { action in
            // Check if action indicates emergency escalation
            return action.data["emergency_level"] as? String == "high"
        }
        
        if !emergencyActions.isEmpty {
            emergencyLevel = .high
        } else if emergencyLevel == .low {
            emergencyLevel = .medium
        }
    }
    
    private func saveSession() {
        guard let session = currentSession else { return }
        
        let sessionData = FlowSessionData(
            session: session,
            completedNodes: Array(completedNodes),
            userResponses: userResponses,
            emergencyLevel: emergencyLevel,
            startTime: startTime,
            lastActivity: lastActivity
        )
        
        do {
            let data = try JSONEncoder().encode(sessionData)
            try secureStorage.store(data: data, key: "flow_session")
        } catch {
            print("Failed to save flow session: \(error)")
        }
    }
    
    private func loadSession() {
        do {
            let data = try secureStorage.retrieve(key: "flow_session")
            let sessionData = try JSONDecoder().decode(FlowSessionData.self, from: data)
            
            currentSession = sessionData.session
            completedNodes = Set(sessionData.completedNodes)
            userResponses = sessionData.userResponses
            emergencyLevel = sessionData.emergencyLevel
            startTime = sessionData.startTime
            lastActivity = sessionData.lastActivity
        } catch {
            // No existing session or error loading
            print("No existing flow session found or error loading: \(error)")
        }
    }
}

struct FlowSession: Codable {
    let id: String
    let flowType: FlowType
    let startTime: Date
    var endTime: Date?
    var status: SessionStatus
}

enum SessionStatus: String, Codable, CaseIterable {
    case active = "active"
    case paused = "paused"
    case completed = "completed"
    case abandoned = "abandoned"
}

enum EmergencyLevel: String, Codable, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
}

struct FlowSessionData: Codable {
    let session: FlowSession
    let completedNodes: [String]
    let userResponses: [String: String]
    let emergencyLevel: EmergencyLevel
    let startTime: Date?
    let lastActivity: Date?
} 