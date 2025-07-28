import Foundation

/// Manages offline caching for crisis response data
class OfflineCache {
    static let shared = OfflineCache()
    
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let maxCacheSize: Int64 = 100 * 1024 * 1024 // 100MB
    
    private init() {
        // Create cache directory
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        cacheDirectory = documentsPath.appendingPathComponent("OfflineCache")
        
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Flow Caching
    
    /// Stores a flow in the cache
    func storeFlow(_ flow: Flow, for flowType: FlowType) async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(flow)
        
        let fileName = "flow_\(flowType.rawValue).json"
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        try data.write(to: fileURL)
        
        // Update cache index
        try await updateCacheIndex()
    }
    
    /// Retrieves a flow from cache
    func getFlow(_ flowType: FlowType) async throws -> Flow? {
        let fileName = "flow_\(flowType.rawValue).json"
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        return try decoder.decode(Flow.self, from: data)
    }
    
    /// Updates a cached flow
    func updateFlow(_ flow: Flow) async throws {
        try await storeFlow(flow, for: flow.type)
    }
    
    /// Deletes a cached flow
    func deleteFlow(id: String) async throws {
        let fileName = "flow_\(id).json"
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
        
        try await updateCacheIndex()
    }
    
    // MARK: - Recommendation Caching
    
    /// Stores recommendations in cache
    func storeRecommendations(_ recommendations: [CloudRecommendation], for crisisType: TriggerType?) async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(recommendations)
        
        let fileName = "recommendations_\(crisisType?.rawValue ?? "general").json"
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        try data.write(to: fileURL)
    }
    
    /// Retrieves cached recommendations
    func getRecommendations(for crisisType: TriggerType?) async throws -> [CloudRecommendation] {
        let fileName = "recommendations_\(crisisType?.rawValue ?? "general").json"
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return []
        }
        
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        return try decoder.decode([CloudRecommendation].self, from: data)
    }
    
    // MARK: - User Feedback Caching
    
    /// Stores user feedback for later sync
    func store(_ feedback: UserFeedback, for key: String) async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(feedback)
        
        let fileName = "feedback_\(key)_\(Date().timeIntervalSince1970).json"
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        try data.write(to: fileURL)
    }
    
    /// Retrieves all pending feedback
    func getPendingFeedback() async throws -> [UserFeedback] {
        let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
        let feedbackFiles = files.filter { $0.lastPathComponent.hasPrefix("feedback_") }
        
        var feedback: [UserFeedback] = []
        let decoder = JSONDecoder()
        
        for file in feedbackFiles {
            do {
                let data = try Data(contentsOf: file)
                let item = try decoder.decode(UserFeedback.self, from: data)
                feedback.append(item)
            } catch {
                print("Failed to decode feedback from \(file): \(error)")
            }
        }
        
        return feedback
    }
    
    /// Clears pending feedback after successful sync
    func clearPendingFeedback() async throws {
        let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
        let feedbackFiles = files.filter { $0.lastPathComponent.hasPrefix("feedback_") }
        
        for file in feedbackFiles {
            try fileManager.removeItem(at: file)
        }
    }
    
    // MARK: - Emergency Content Caching
    
    /// Stores emergency content for offline access
    func storeEmergencyContent(_ content: EmergencyContent) async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(content)
        
        let fileName = "emergency_content_\(content.type.rawValue).json"
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        try data.write(to: fileURL)
    }
    
    /// Retrieves cached emergency content
    func getEmergencyContent(for type: EmergencyContentType) async throws -> EmergencyContent? {
        let fileName = "emergency_content_\(type.rawValue).json"
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        return try decoder.decode(EmergencyContent.self, from: data)
    }
    
    // MARK: - Legal Information Caching
    
    /// Stores legal information for offline access
    func storeLegalInfo(_ legalInfo: LegalInformation, for state: String) async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(legalInfo)
        
        let fileName = "legal_\(state.lowercased()).json"
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        try data.write(to: fileURL)
    }
    
    /// Retrieves cached legal information
    func getLegalInfo(for state: String) async throws -> LegalInformation? {
        let fileName = "legal_\(state.lowercased()).json"
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        return try decoder.decode(LegalInformation.self, from: data)
    }
    
    // MARK: - Cache Management
    
    /// Updates the cache index
    func updateCacheIndex() async throws {
        let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey, .creationDateKey])
        
        var index: [String: CacheIndexEntry] = [:]
        
        for file in files {
            let attributes = try file.resourceValues(forKeys: [.fileSizeKey, .creationDateKey])
            let size = attributes.fileSize ?? 0
            let date = attributes.creationDate ?? Date()
            
            index[file.lastPathComponent] = CacheIndexEntry(
                fileName: file.lastPathComponent,
                size: size,
                created: date,
                lastAccessed: Date()
            )
        }
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(index)
        let indexURL = cacheDirectory.appendingPathComponent("cache_index.json")
        try data.write(to: indexURL)
    }
    
    /// Clears expired cache entries
    func clearExpiredCache() async throws {
        let maxAge: TimeInterval = 7 * 24 * 60 * 60 // 7 days
        let cutoffDate = Date().addingTimeInterval(-maxAge)
        
        let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.creationDateKey])
        
        for file in files {
            let attributes = try file.resourceValues(forKeys: [.creationDateKey])
            if let creationDate = attributes.creationDate, creationDate < cutoffDate {
                try fileManager.removeItem(at: file)
            }
        }
        
        try await updateCacheIndex()
    }
    
    /// Manages cache size
    func manageCacheSize() async throws {
        let currentSize = try await getCacheSize()
        
        if currentSize > maxCacheSize {
            try await trimCache(to: maxCacheSize * 3 / 4) // Trim to 75% of max size
        }
    }
    
    /// Gets current cache size
    func getCacheSize() async throws -> Int64 {
        let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey])
        
        var totalSize: Int64 = 0
        for file in files {
            let attributes = try file.resourceValues(forKeys: [.fileSizeKey])
            totalSize += Int64(attributes.fileSize ?? 0)
        }
        
        return totalSize
    }
    
    /// Trims cache to specified size
    func trimCache(to targetSize: Int64) async throws {
        let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey, .creationDateKey])
        
        // Sort files by creation date (oldest first)
        let sortedFiles = files.sorted { file1, file2 in
            let attributes1 = try? file1.resourceValues(forKeys: [.creationDateKey])
            let attributes2 = try? file2.resourceValues(forKeys: [.creationDateKey])
            return (attributes1?.creationDate ?? Date.distantPast) < (attributes2?.creationDate ?? Date.distantPast)
        }
        
        var currentSize = try await getCacheSize()
        
        for file in sortedFiles {
            if currentSize <= targetSize {
                break
            }
            
            let attributes = try file.resourceValues(forKeys: [.fileSizeKey])
            let fileSize = Int64(attributes.fileSize ?? 0)
            
            try fileManager.removeItem(at: file)
            currentSize -= fileSize
        }
        
        try await updateCacheIndex()
    }
    
    /// Refreshes the cache
    func refresh() async throws {
        try await clearExpiredCache()
        try await manageCacheSize()
    }
    
    /// Clears all cached data
    func clearAll() async throws {
        let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
        
        for file in files {
            try fileManager.removeItem(at: file)
        }
    }
}

// MARK: - Supporting Types

struct LegalInformation: Codable {
    let state: String
    let title: String
    let content: String
    let lastUpdated: Date
    let version: String
    let source: String
    let tags: [String]
    
    init(
        state: String,
        title: String,
        content: String,
        lastUpdated: Date = Date(),
        version: String = "1.0",
        source: String = "State Legal Database",
        tags: [String] = []
    ) {
        self.state = state
        self.title = title
        self.content = content
        self.lastUpdated = lastUpdated
        self.version = version
        self.source = source
        self.tags = tags
    }
}

struct CacheIndexEntry: Codable {
    let fileName: String
    let size: Int
    let created: Date
    let lastAccessed: Date
} 