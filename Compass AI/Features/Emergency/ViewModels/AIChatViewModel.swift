import SwiftUI
import Speech
import AVFoundation

@MainActor
class AIChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isAITyping = false
    @Published var isListening = false
    
    private let localAI = LocalAI()
    private let triggerDetector = TriggerDetector()
    private let speechRecognizer = SpeechRecognizer()
    
    func sendMessage(_ text: String) {
        // Add user message
        let userMessage = ChatMessage(content: text, isUser: true)
        messages.append(userMessage)
        
        // Check for crisis triggers
        let triggers = triggerDetector.detectTriggers(in: text)
        
        if triggerDetector.hasHighPriorityTriggers(in: text) {
            // Immediate crisis - use local response
            handleImmediateCrisis(text: text, triggers: triggers)
        } else {
            // Normal response - can use AI
            generateAIResponse(for: text, triggers: triggers)
        }
    }
    
    private func handleImmediateCrisis(text: String, triggers: [Trigger]) {
        isAITyping = true
        
        // Immediate local response
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isAITyping = false
            
            var response = ""
            
            let triggerTypes = Set(triggers.map { $0.type })
            
            if triggerTypes.contains(.suicide) {
                response = """
                I hear you're going through something incredibly difficult right now. You don't have to face this alone.
                
                Please reach out for immediate support:
                • Call 988 (Suicide & Crisis Lifeline) - available 24/7
                • Text "HELLO" to 741741 (Crisis Text Line)
                • If you're in immediate danger, call 911
                
                Would you like me to help you connect with someone right now?
                """
            } else if triggerTypes.contains(.violence) {
                response = """
                Your safety is the most important thing right now. Here's what you can do:
                
                • If you're in immediate danger, call 911
                • National Domestic Violence Hotline: 1-800-799-7233
                • Text "START" to 88788
                
                Do you need help making a safety plan or finding a safe place?
                """
            } else if triggerTypes.contains(.medical) {
                response = """
                This sounds like a medical emergency. Here's what to do:
                
                • Call 911 immediately if life-threatening
                • Poison Control: 1-800-222-1222
                • Have someone drive you to the ER if possible
                
                What symptoms are you experiencing right now?
                """
            }
            
            let aiMessage = ChatMessage(content: response, isUser: false)
            self?.messages.append(aiMessage)
            
            // Haptic for urgent response
            HapticService.shared.notification(.warning)
        }
    }
    
    private func generateAIResponse(for text: String, triggers: [Trigger]) {
        isAITyping = true
        
        Task {
            do {
                // Try online AI first, fallback to local
                let response = await localAI.generateResponse(
                    for: text,
                    context: .crisis,
                    triggers: triggers
                )
                
                await MainActor.run {
                    self.isAITyping = false
                    let aiMessage = ChatMessage(content: response, isUser: false)
                    self.messages.append(aiMessage)
                }
            } catch {
                // Fallback to pre-written response
                await MainActor.run {
                    self.isAITyping = false
                    self.showFallbackResponse()
                }
            }
        }
    }
    
    private func showFallbackResponse() {
        let response = "I understand you're going through something difficult. Can you tell me more about what's happening? I'm here to help guide you through this."
        let aiMessage = ChatMessage(content: response, isUser: false)
        messages.append(aiMessage)
    }
    
    func startListening() {
        speechRecognizer.startListening { [weak self] text in
            self?.sendMessage(text)
            self?.isListening = false
        }
    }
    
    func stopListening() {
        speechRecognizer.stopListening()
        isListening = false
    }
    
    func triggerEmergencyMode() {
        // Switch to emergency flow
        NotificationCenter.default.post(name: .triggerEmergencyMode, object: nil)
    }
}

// Chat Message Model
struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp = Date()
}

// Crisis Triggers
enum CrisisTrigger {
    case immediate
    case suicide
    case violence
    case medical
    case police
    case panic
} 