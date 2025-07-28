import Foundation
import SwiftUI

/// Main flow engine that manages crisis response flows
class FlowEngine: ObservableObject {
    @Published var currentFlow: Flow?
    @Published var currentNode: FlowNode?
    @Published var flowState: FlowState = .idle
    
    private let stateManager: FlowStateManager
    private let validator: FlowValidator
    
    init() {
        self.stateManager = FlowStateManager()
        self.validator = FlowValidator()
    }
    
    func loadFlow(_ flowType: FlowType) async throws {
        flowState = .loading
        
        do {
            let flow = try await FlowRepository.shared.loadFlow(flowType)
            currentFlow = flow
            currentNode = flow.startNode
            flowState = .ready
        } catch {
            flowState = .error(error)
            throw error
        }
    }
    
    func executeNode(_ node: FlowNode) async throws -> FlowNode? {
        guard validator.canExecute(node) else {
            throw FlowError.invalidNode
        }
        
        flowState = .executing
        
        // Execute node logic
        let result = try await node.execute()
        
        // Update state
        stateManager.updateState(with: result)
        
        // Get next node
        let nextNode = node.getNextNode(based: result)
        currentNode = nextNode
        
        flowState = nextNode != nil ? .ready : .completed
        
        return nextNode
    }
    
    func resetFlow() {
        currentFlow = nil
        currentNode = nil
        flowState = .idle
        stateManager.reset()
    }
}

enum FlowState {
    case idle
    case loading
    case ready
    case executing
    case completed
    case error(Error)
}

enum FlowType: String, Codable, CaseIterable {
    case panic = "panic"
    case police = "police"
    case domesticViolence = "domestic_violence"
    case suicide = "suicide"
    case medical = "medical"
    case disaster = "disaster"
    case custom = "custom"
}

enum FlowError: Error {
    case invalidNode
    case flowNotFound
    case executionFailed
} 