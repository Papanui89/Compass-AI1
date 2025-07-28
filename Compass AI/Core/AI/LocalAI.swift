import Foundation
import CoreML
import NaturalLanguage

/// Handles on-device AI processing for crisis detection and response
class LocalAI: ObservableObject {
    @Published var isProcessing = false
    @Published var confidence: Double = 0.0
    
    private var crisisClassifier: MLModel?
    private var textAnalyzer: NLModel?
    private let triggerDetector = TriggerDetector()
    
    init() {
        loadModels()
    }
    
    /// Analyzes text for crisis indicators
    func analyzeText(_ text: String) async throws -> CrisisAnalysis {
        isProcessing = true
        defer { isProcessing = false }
        
        // Check for trigger words first
        let triggers = triggerDetector.detectTriggers(in: text)
        
        // Perform sentiment analysis
        let sentiment = try await analyzeSentiment(text)
        
        // Check for crisis keywords
        let crisisKeywords = detectCrisisKeywords(in: text)
        
        // Calculate overall risk score
        let riskScore = calculateRiskScore(
            triggers: triggers,
            sentiment: sentiment,
            keywords: crisisKeywords
        )
        
        return CrisisAnalysis(
            text: text,
            riskScore: riskScore,
            triggers: triggers,
            sentiment: sentiment,
            crisisKeywords: crisisKeywords,
            confidence: confidence
        )
    }
    
    /// Analyzes user behavior patterns
    func analyzeBehavior(_ behavior: UserBehavior) async throws -> BehaviorAnalysis {
        // Analyze patterns in user interactions
        let patterns = detectBehaviorPatterns(behavior)
        
        // Check for concerning patterns
        let concerningPatterns = patterns.filter { pattern in
            pattern.riskLevel == .medium || pattern.riskLevel == .high || pattern.riskLevel == .critical
        }
        
        return BehaviorAnalysis(
            patterns: patterns,
            concerningPatterns: concerningPatterns,
            overallRisk: calculateBehaviorRisk(patterns)
        )
    }
    
    /// Processes audio for crisis indicators
    func analyzeAudio(_ audioData: Data) async throws -> AudioAnalysis {
        // Convert audio to text (would use Speech framework)
        let transcribedText = try await transcribeAudio(audioData)
        
        // Analyze the transcribed text
        let textAnalysis = try await analyzeText(transcribedText)
        
        // Analyze audio characteristics (tone, volume, etc.)
        let audioCharacteristics = analyzeAudioCharacteristics(audioData)
        
        return AudioAnalysis(
            transcribedText: transcribedText,
            textAnalysis: textAnalysis,
            characteristics: audioCharacteristics
        )
    }
    
    /// Provides personalized crisis response suggestions
    func suggestResponse(for crisis: CrisisAnalysis) async throws -> [CrisisResponse] {
        var suggestions: [CrisisResponse] = []
        
        // Based on risk level
        switch crisis.riskScore {
        case 0.0..<0.3:
            suggestions.append(.monitor)
        case 0.3..<0.6:
            suggestions.append(.checkIn)
            suggestions.append(.provideResources)
        case 0.6..<0.8:
            suggestions.append(.immediateSupport)
            suggestions.append(.emergencyContact)
        case 0.8...1.0:
            suggestions.append(.emergencyIntervention)
            suggestions.append(.immediateSupport)
        default:
            suggestions.append(.monitor)
        }
        
        // Based on specific triggers
        for trigger in crisis.triggers {
            switch trigger.type {
            case .suicide:
                suggestions.append(.suicidePrevention)
            case .violence:
                suggestions.append(.violencePrevention)
            case .medical:
                suggestions.append(.medicalEmergency)
            case .abuse:
                suggestions.append(.abuseSupport)
            case .mentalHealth:
                suggestions.append(.provideResources)
            }
        }
        
        return suggestions
    }
    
    // MARK: - Private Methods
    
    private func loadModels() {
        // Load Core ML models for crisis detection
        // This would load pre-trained models for text classification
        // and crisis detection
    }
    
    private func analyzeSentiment(_ text: String) async throws -> SentimentAnalysis {
        // Use Natural Language framework for basic text analysis
        let tagger = NLTagger(tagSchemes: [.tokenType, .language, .lemma])
        tagger.string = text
        
        var sentiment: Sentiment = .neutral
        var confidence: Double = 0.0
        
        // Simple sentiment analysis based on keyword detection
        let positiveWords = ["good", "great", "excellent", "happy", "love", "wonderful", "amazing"]
        let negativeWords = ["bad", "terrible", "awful", "hate", "sad", "angry", "depressed", "suicide", "kill", "die"]
        
        let lowercasedText = text.lowercased()
        var positiveCount = 0
        var negativeCount = 0
        
        for word in positiveWords {
            if lowercasedText.contains(word) {
                positiveCount += 1
            }
        }
        
        for word in negativeWords {
            if lowercasedText.contains(word) {
                negativeCount += 1
            }
        }
        
        if negativeCount > positiveCount {
            sentiment = .negative
            confidence = min(Double(negativeCount) / 10.0, 1.0)
        } else if positiveCount > negativeCount {
            sentiment = .positive
            confidence = min(Double(positiveCount) / 10.0, 1.0)
        } else {
            sentiment = .neutral
            confidence = 0.5
        }
        
        return SentimentAnalysis(sentiment: sentiment, confidence: confidence)
    }
    
    private func detectCrisisKeywords(in text: String) -> [CrisisKeyword] {
        let crisisKeywords: [String: CrisisType] = [
            "suicide": .suicide,
            "kill myself": .suicide,
            "end it all": .suicide,
            "violence": .violence,
            "hurt": .violence,
            "attack": .violence,
            "abuse": .abuse,
            "domestic": .abuse,
            "medical": .medicalEmergency,
            "emergency": .medicalEmergency,
            "pain": .medicalEmergency
        ]
        
        var detected: [CrisisKeyword] = []
        let lowercased = text.lowercased()
        
        for (keyword, type) in crisisKeywords {
            if lowercased.contains(keyword) {
                detected.append(CrisisKeyword(keyword: keyword, type: type))
            }
        }
        
        return detected
    }
    
    private func calculateRiskScore(triggers: [Trigger], sentiment: SentimentAnalysis, keywords: [CrisisKeyword]) -> Double {
        var score: Double = 0.0
        
        // Base score from triggers
        score += Double(triggers.count) * 0.2
        
        // Sentiment contribution
        switch sentiment.sentiment {
        case .negative:
            score += 0.3
        case .positive:
            score -= 0.1
        case .neutral:
            break
        }
        
        // Keyword contribution
        score += Double(keywords.count) * 0.15
        
        // Normalize to 0-1 range
        return min(max(score, 0.0), 1.0)
    }
    
    private func detectBehaviorPatterns(_ behavior: UserBehavior) -> [BehaviorPattern] {
        // Analyze user behavior patterns
        // This would look at timing, frequency, and types of interactions
        return []
    }
    
    private func calculateBehaviorRisk(_ patterns: [BehaviorPattern]) -> Double {
        // Calculate overall risk based on behavior patterns
        return 0.0
    }
    
    private func transcribeAudio(_ audioData: Data) async throws -> String {
        // Use Speech framework to transcribe audio
        // This is a placeholder implementation
        return ""
    }
    
    private func analyzeAudioCharacteristics(_ audioData: Data) -> AudioCharacteristics {
        // Analyze audio characteristics like volume, tone, etc.
        return AudioCharacteristics(volume: 0.0, tone: .neutral, clarity: 0.0)
    }
}

// MARK: - Supporting Types

struct CrisisAnalysis {
    let text: String
    let riskScore: Double
    let triggers: [Trigger]
    let sentiment: SentimentAnalysis
    let crisisKeywords: [CrisisKeyword]
    let confidence: Double
}

struct SentimentAnalysis {
    let sentiment: Sentiment
    let confidence: Double
}

enum Sentiment: String, Codable {
    case positive
    case negative
    case neutral
}

struct CrisisKeyword {
    let keyword: String
    let type: CrisisType
}

struct BehaviorAnalysis {
    let patterns: [BehaviorPattern]
    let concerningPatterns: [BehaviorPattern]
    let overallRisk: Double
}

struct BehaviorPattern {
    let type: PatternType
    let frequency: Int
    let riskLevel: CrisisRiskLevel
}

enum PatternType {
    case rapidInteraction
    case lateNightUsage
    case crisisKeywordSearch
    case emergencyContactAccess
}

enum CrisisRiskLevel {
    case low
    case medium
    case high
    case critical
}

struct AudioAnalysis {
    let transcribedText: String
    let textAnalysis: CrisisAnalysis
    let characteristics: AudioCharacteristics
}

struct AudioCharacteristics {
    let volume: Double
    let tone: Tone
    let clarity: Double
}

enum Tone {
    case calm
    case agitated
    case distressed
    case neutral
}

struct UserBehavior {
    let interactions: [UserInteraction]
    let timeStamps: [Date]
    let features: [String: Any]
}

enum CrisisResponse {
    case monitor
    case checkIn
    case provideResources
    case immediateSupport
    case emergencyContact
    case emergencyIntervention
    case suicidePrevention
    case violencePrevention
    case medicalEmergency
    case abuseSupport
} 
