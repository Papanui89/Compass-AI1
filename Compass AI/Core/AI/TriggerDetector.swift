import Foundation
import NaturalLanguage

/// Detects crisis triggers and keywords in text input
class TriggerDetector {
    
    private var triggerWords: [String: TriggerType] = [:]
    private var triggerPatterns: [TriggerPattern] = []
    
    init() {
        loadTriggers()
    }
    
    /// Detects triggers in the given text
    func detectTriggers(in text: String) -> [Trigger] {
        var detectedTriggers: [Trigger] = []
        let lowercasedText = text.lowercased()
        
        // Check for individual trigger words
        for (word, type) in triggerWords {
            if lowercasedText.contains(word) {
                let trigger = Trigger(
                    word: word,
                    type: type,
                    confidence: calculateConfidence(for: word, in: text),
                    context: extractContext(around: word, in: text)
                )
                detectedTriggers.append(trigger)
            }
        }
        
        // Check for trigger patterns
        for pattern in triggerPatterns {
            if pattern.matches(text) {
                let trigger = Trigger(
                    word: pattern.pattern,
                    type: pattern.type,
                    confidence: pattern.confidence,
                    context: extractContext(around: pattern.pattern, in: text)
                )
                detectedTriggers.append(trigger)
            }
        }
        
        // Remove duplicates and sort by confidence
        return Array(Set(detectedTriggers)).sorted { $0.confidence > $1.confidence }
    }
    
    /// Checks if text contains any high-priority triggers
    func hasHighPriorityTriggers(in text: String) -> Bool {
        let triggers = detectTriggers(in: text)
        return triggers.contains { trigger in
            trigger.type.priority == .high
        }
    }
    
    /// Gets the most severe trigger type in the text
    func getMostSevereTrigger(in text: String) -> TriggerType? {
        let triggers = detectTriggers(in: text)
        return triggers.max { $0.type.severity < $1.type.severity }?.type
    }
    
    /// Analyzes trigger frequency in a conversation
    func analyzeTriggerFrequency(in conversation: [String]) -> TriggerFrequency {
        var frequencyMap: [TriggerType: Int] = [:]
        
        for message in conversation {
            let triggers = detectTriggers(in: message)
            for trigger in triggers {
                frequencyMap[trigger.type, default: 0] += 1
            }
        }
        
        return TriggerFrequency(frequencyMap: frequencyMap)
    }
    
    // MARK: - Private Methods
    
    private func loadTriggers() {
        // Load trigger words from configuration
        triggerWords = [
            // Suicide-related triggers
            "suicide": .suicide,
            "kill myself": .suicide,
            "end it all": .suicide,
            "want to die": .suicide,
            "better off dead": .suicide,
            "no reason to live": .suicide,
            "give up": .suicide,
            
            // Violence-related triggers
            "hurt someone": .violence,
            "attack": .violence,
            "fight": .violence,
            "violent": .violence,
            "weapon": .violence,
            "gun": .violence,
            "knife": .violence,
            
            // Abuse-related triggers
            "abuse": .abuse,
            "domestic violence": .abuse,
            "beaten": .abuse,
            "hit me": .abuse,
            "scared": .abuse,
            "afraid": .abuse,
            "threatened": .abuse,
            
            // Medical emergency triggers
            "medical emergency": .medical,
            "chest pain": .medical,
            "can't breathe": .medical,
            "overdose": .medical,
            "bleeding": .medical,
            "unconscious": .medical,
            "seizure": .medical,
            
            // Mental health triggers
            "depression": .mentalHealth,
            "anxiety": .mentalHealth,
            "panic attack": .mentalHealth,
            "hallucinations": .mentalHealth,
            "paranoia": .mentalHealth,
            "self-harm": .mentalHealth,
            "cutting": .mentalHealth
        ]
        
        // Load trigger patterns
        triggerPatterns = [
            TriggerPattern(
                pattern: "I want to (kill|end|hurt) myself",
                type: .suicide,
                confidence: 0.9,
                regex: try! NSRegularExpression(pattern: "I want to (kill|end|hurt) myself", options: .caseInsensitive)
            ),
            TriggerPattern(
                pattern: "I'm going to (kill|end|hurt) myself",
                type: .suicide,
                confidence: 0.95,
                regex: try! NSRegularExpression(pattern: "I'm going to (kill|end|hurt) myself", options: .caseInsensitive)
            ),
            TriggerPattern(
                pattern: "I feel like (killing|ending|hurting) myself",
                type: .suicide,
                confidence: 0.8,
                regex: try! NSRegularExpression(pattern: "I feel like (killing|ending|hurting) myself", options: .caseInsensitive)
            )
        ]
    }
    
    private func calculateConfidence(for word: String, in text: String) -> Double {
        var confidence: Double = 0.5 // Base confidence
        
        // Increase confidence based on context
        let context = extractContext(around: word, in: text)
        
        // Check for intensifiers
        let intensifiers = ["really", "very", "extremely", "completely", "totally"]
        for intensifier in intensifiers {
            if context.lowercased().contains(intensifier) {
                confidence += 0.2
            }
        }
        
        // Check for negation (decreases confidence)
        let negations = ["not", "don't", "doesn't", "didn't", "won't", "can't"]
        for negation in negations {
            if context.lowercased().contains(negation) {
                confidence -= 0.3
            }
        }
        
        // Check for past tense (decreases urgency)
        if context.lowercased().contains("was") || context.lowercased().contains("were") {
            confidence -= 0.1
        }
        
        return max(0.0, min(1.0, confidence))
    }
    
    private func extractContext(around word: String, in text: String) -> String {
        guard let range = text.lowercased().range(of: word.lowercased()) else {
            return text
        }
        
        let startIndex = text.index(range.lowerBound, offsetBy: -50, limitedBy: text.startIndex) ?? text.startIndex
        let endIndex = text.index(range.upperBound, offsetBy: 50, limitedBy: text.endIndex) ?? text.endIndex
        
        return String(text[startIndex..<endIndex])
    }
}

// MARK: - Supporting Types

struct Trigger: Hashable, Codable {
    let word: String
    let type: TriggerType
    let confidence: Double
    let context: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(word)
        hasher.combine(type)
    }
    
    static func == (lhs: Trigger, rhs: Trigger) -> Bool {
        return lhs.word == rhs.word && lhs.type == rhs.type
    }
}

enum TriggerType: String, Codable, CaseIterable {
    case suicide
    case violence
    case abuse
    case medical
    case mentalHealth
    
    var priority: TriggerPriority {
        switch self {
        case .suicide, .medical:
            return .high
        case .violence, .abuse:
            return .medium
        case .mentalHealth:
            return .low
        }
    }
    
    var severity: Int {
        switch self {
        case .suicide:
            return 5
        case .medical:
            return 4
        case .violence:
            return 3
        case .abuse:
            return 2
        case .mentalHealth:
            return 1
        }
    }
}

enum TriggerPriority {
    case low
    case medium
    case high
}

struct TriggerPattern {
    let pattern: String
    let type: TriggerType
    let confidence: Double
    let regex: NSRegularExpression
    
    func matches(_ text: String) -> Bool {
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return regex.firstMatch(in: text, options: [], range: range) != nil
    }
}

struct TriggerFrequency {
    let frequencyMap: [TriggerType: Int]
    
    var mostFrequent: TriggerType? {
        return frequencyMap.max { $0.value < $1.value }?.key
    }
    
    var totalTriggers: Int {
        return frequencyMap.values.reduce(0, +)
    }
    
    func frequency(for type: TriggerType) -> Int {
        return frequencyMap[type] ?? 0
    }
} 