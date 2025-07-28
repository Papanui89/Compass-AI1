import Foundation

/// Repository for managing crisis response flows
class FlowRepository {
    static let shared = FlowRepository()
    
    private let secureStorage = SecureStorage.shared
    private let offlineCache = OfflineCache.shared
    
    private init() {}
    
    /// Loads a crisis flow by type
    func loadFlow(_ flowType: FlowType) async throws -> Flow {
        // Try to load from cache first
        if let cachedFlow = try await offlineCache.getFlow(flowType) {
            return cachedFlow
        }
        
        // Load from bundled resources
        let flow = try await loadBundledFlow(flowType)
        
        // Cache the flow for offline use
        try await offlineCache.storeFlow(flow, for: flowType)
        
        return flow
    }
    
    /// Loads all available flows
    func loadAllFlows() async throws -> [Flow] {
        var flows: [Flow] = []
        
        for flowType in FlowType.allCases {
            do {
                let flow = try await loadFlow(flowType)
                flows.append(flow)
            } catch {
                print("Failed to load flow \(flowType): \(error)")
            }
        }
        
        return flows
    }
    
    /// Saves a custom flow
    func saveCustomFlow(_ flow: Flow) async throws {
        // Validate the flow
        let validator = FlowValidator()
        let errors = validator.validateFlow(flow)
        
        guard errors.isEmpty else {
            throw FlowRepositoryError.validationFailed(errors)
        }
        
        // Store in secure storage
        try secureStorage.store(flow, key: "custom_flow_\(flow.id)")
        
        // Update cache
        try await offlineCache.storeFlow(flow, for: .custom)
    }
    
    /// Loads a custom flow by ID
    func loadCustomFlow(id: String) async throws -> Flow? {
        return try secureStorage.retrieve(Flow.self, key: "custom_flow_\(id)")
    }
    
    /// Deletes a custom flow
    func deleteCustomFlow(id: String) async throws {
        try secureStorage.delete(key: "custom_flow_\(id)")
        try await offlineCache.deleteFlow(id: id)
    }
    
    /// Gets all custom flows
    func getAllCustomFlows() async throws -> [Flow] {
        let keys = try secureStorage.getAllKeys()
        let customFlowKeys = keys.filter { $0.hasPrefix("custom_flow_") }
        
        var flows: [Flow] = []
        for key in customFlowKeys {
            do {
                let flow = try secureStorage.retrieve(Flow.self, key: key)
                flows.append(flow)
            } catch {
                // Skip flows that can't be retrieved
                continue
            }
        }
        
        return flows
    }
    
    /// Updates a flow with new data
    func updateFlow(_ flow: Flow) async throws {
        // Validate the updated flow
        let validator = FlowValidator()
        let errors = validator.validateFlow(flow)
        
        guard errors.isEmpty else {
            throw FlowRepositoryError.validationFailed(errors)
        }
        
        // Update storage
        try secureStorage.store(flow, key: "flow_\(flow.id)")
        
        // Update cache
        try await offlineCache.updateFlow(flow)
    }
    
    /// Exports a flow to JSON
    func exportFlow(_ flow: Flow) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(flow)
    }
    
    /// Imports a flow from JSON
    func importFlow(from data: Data) async throws -> Flow {
        let decoder = JSONDecoder()
        let flow = try decoder.decode(Flow.self, from: data)
        
        // Validate the imported flow
        let validator = FlowValidator()
        let errors = validator.validateFlow(flow)
        
        guard errors.isEmpty else {
            throw FlowRepositoryError.validationFailed(errors)
        }
        
        // Save the imported flow
        try await saveCustomFlow(flow)
        
        return flow
    }
    
    /// Gets flow statistics
    func getFlowStatistics() async throws -> FlowStatistics {
        let allFlows = try await loadAllFlows()
        let customFlows = try await getAllCustomFlows()
        
        var typeCounts: [FlowType: Int] = [:]
        for flow in allFlows {
            typeCounts[flow.type, default: 0] += 1
        }
        
        return FlowStatistics(
            totalFlows: allFlows.count,
            customFlows: customFlows.count,
            typeDistribution: typeCounts,
            lastUpdated: Date()
        )
    }
    
    /// Syncs flows with cloud storage
    func syncFlows() async throws {
        // This would sync with cloud storage when implemented
        // For now, just update local cache
        try await offlineCache.refresh()
    }
    
    // MARK: - Private Methods
    
    private func loadBundledFlow(_ flowType: FlowType) async throws -> Flow {
        guard let url = Bundle.main.url(forResource: flowType.rawValue, withExtension: "json", subdirectory: "Resources/Flows") else {
            throw FlowRepositoryError.flowNotFound(flowType)
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(Flow.self, from: data)
    }
}

// MARK: - Supporting Types

struct Flow: Codable {
    let id: String
    let type: FlowType
    let title: String
    let description: String
    let version: String
    let startNode: FlowNode?
    let nodes: [FlowNode]
    let metadata: FlowMetadata
    let createdAt: Date
    let updatedAt: Date
}

enum FlowDifficulty: String, Codable, CaseIterable {
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"
    case expert = "expert"
}

struct FlowStatistics: Codable {
    let totalFlows: Int
    let customFlows: Int
    let typeDistribution: [String: Int] // Using String keys for Codable compatibility
    let lastUpdated: Date
    
    init(totalFlows: Int, customFlows: Int, typeDistribution: [FlowType: Int], lastUpdated: Date) {
        self.totalFlows = totalFlows
        self.customFlows = customFlows
        self.typeDistribution = Dictionary(uniqueKeysWithValues: typeDistribution.map { ($0.rawValue, $1) })
        self.lastUpdated = lastUpdated
    }
}

enum FlowRepositoryError: Error, LocalizedError {
    case flowNotFound(FlowType)
    case validationFailed([ValidationError])
    case importFailed(Error)
    case exportFailed(Error)
    case storageError(Error)
    
    var errorDescription: String? {
        switch self {
        case .flowNotFound(let flowType):
            return "Flow not found: \(flowType.rawValue)"
        case .validationFailed(let errors):
            return "Flow validation failed: \(errors.map { $0.localizedDescription }.joined(separator: ", "))"
        case .importFailed(let error):
            return "Failed to import flow: \(error.localizedDescription)"
        case .exportFailed(let error):
            return "Failed to export flow: \(error.localizedDescription)"
        case .storageError(let error):
            return "Storage error: \(error.localizedDescription)"
        }
    }
} 