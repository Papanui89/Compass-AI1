import SwiftUI
import Foundation
import AVFoundation

class ConversationalFlowViewModel: ObservableObject {
    @Published var currentFlow: ConversationalFlow?
    @Published var currentNode: ConversationalNode?
    @Published var messages: [ChatMessage] = []
    @Published var currentOptions: [ConversationOption] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var isFlowActive = false
    @Published var isTyping = false
    
    private let flowRepository = FlowRepository.shared
    private let synthesizer = AVSpeechSynthesizer()
    
    init() {
        print("🔍 ConversationalFlowViewModel: Initialized")
    }
    
    func loadFlow(for crisisType: CrisisType) async {
        print("🔍 ConversationalFlowViewModel: Loading flow for crisis type: \(crisisType)")
        
        await MainActor.run {
            isLoading = true
            error = nil
            messages = []
            currentOptions = []
            isTyping = false
        }
        
        do {
            // Convert CrisisType to FlowType
            let flowType = convertCrisisTypeToFlowType(crisisType)
            print("🔍 ConversationalFlowViewModel: Converted to FlowType: \(flowType.rawValue)")
            
            // Load the conversational flow
            let flow = try await flowRepository.loadConversationalFlow(flowType)
            
            await MainActor.run {
                self.currentFlow = flow
                print("✅ ConversationalFlowViewModel: Successfully loaded flow: \(flow.title)")
                print("✅ ConversationalFlowViewModel: Flow has \(flow.nodes.count) nodes")
                
                // Start the flow
                self.startFlow()
            }
        } catch {
            print("❌ ConversationalFlowViewModel: Failed to load flow: \(error)")
            await MainActor.run {
                self.error = "Failed to load flow: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    private func convertCrisisTypeToFlowType(_ crisisType: CrisisType) -> FlowType {
        switch crisisType {
        case .panicAttack:
            return .panic
        case .domesticViolence:
            return .domesticViolence
        case .suicide:
            return .suicide
        case .medicalEmergency:
            return .medical
        case .naturalDisaster:
            return .disaster
        case .bullying:
            return .panic // Use panic flow for now, can be updated later
        default:
            return .panic
        }
    }
    
    private func startFlow() {
        guard let flow = currentFlow else {
            print("❌ ConversationalFlowViewModel: No flow loaded")
            return
        }
        
        print("🔍 ConversationalFlowViewModel: Starting flow with startNode: \(flow.startNode)")
        
        // Find the start node
        guard let startNode = flow.nodes.first(where: { $0.id == flow.startNode }) else {
            print("❌ ConversationalFlowViewModel: Start node not found: \(flow.startNode)")
            error = "Start node not found"
            isLoading = false
            return
        }
        
        currentNode = startNode
        isFlowActive = true
        isLoading = false
        
        print("✅ ConversationalFlowViewModel: Flow started successfully")
        
        // Start displaying messages with typing animation
        displayNode(startNode)
    }
    
    private func displayNode(_ node: ConversationalNode) {
        print("🔍 ConversationalFlowViewModel: Displaying node: \(node.id)")
        print("🔍 ConversationalFlowViewModel: Node has \(node.messages.count) messages")
        print("🔍 ConversationalFlowViewModel: Node has \(node.options?.count ?? 0) options")
        print("🔍 ConversationalFlowViewModel: Node has nextNode: \(node.nextNode ?? "none")")
        
        if let options = node.options {
            print("🔍 ConversationalFlowViewModel: Options are: \(options.map { $0.text })")
        }
        
        // Add messages one by one with typing animation
        for (index, message) in node.messages.enumerated() {
            let delay = Double(index) * 2.0 // Increased delay for more natural conversation
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.showTypingIndicator()
                
                // Simulate typing time based on message length
                let typingTime = min(Double(message.count) * 0.05, 2.0) // Max 2 seconds
                
                DispatchQueue.main.asyncAfter(deadline: .now() + typingTime) {
                    self.hideTypingIndicator()
                    self.addMessage(message, isFromUser: false)
                }
            }
        }
        
        // Show options after messages (if any) - FIXED TIMING
        if let options = node.options {
            let totalMessageTime = Double(node.messages.count) * 2.0 + 1.0
            print("🔍 ConversationalFlowViewModel: Will show options in \(totalMessageTime) seconds")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + totalMessageTime) {
                print("✅ ConversationalFlowViewModel: Setting \(options.count) options")
                self.currentOptions = options
                print("✅ ConversationalFlowViewModel: currentOptions count is now: \(self.currentOptions.count)")
            }
        } else {
            print("❌ ConversationalFlowViewModel: No options found in node")
            
            // If no options but has nextNode, automatically progress after messages
            if let nextNodeId = node.nextNode {
                let totalMessageTime = Double(node.messages.count) * 2.0 + 2.0
                print("🔍 ConversationalFlowViewModel: Will auto-progress to \(nextNodeId) in \(totalMessageTime) seconds")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + totalMessageTime) {
                    self.progressToNextNode(nextNodeId)
                }
            }
        }
        
        // Execute action if specified
        if let action = node.action {
            let totalMessageTime = Double(node.messages.count) * 2.0 + 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + totalMessageTime) {
                self.executeAction(action)
            }
        }
    }
    
    private func progressToNextNode(_ nextNodeId: String) {
        print("🔍 ConversationalFlowViewModel: Progressing to next node: \(nextNodeId)")
        
        guard let flow = currentFlow,
              let nextNode = flow.nodes.first(where: { $0.id == nextNodeId }) else {
            print("❌ ConversationalFlowViewModel: Next node not found: \(nextNodeId)")
            error = "Next node not found"
            return
        }
        
        currentNode = nextNode
        displayNode(nextNode)
    }
    
    private func showTypingIndicator() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isTyping = true
        }
    }
    
    private func hideTypingIndicator() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isTyping = false
        }
    }
    
    func selectOption(_ option: ConversationOption) {
        print("🔍 ConversationalFlowViewModel: User selected option: \(option.text)")
        
        // Add user's choice to messages
        addMessage(option.text, isFromUser: true)
        
        // Clear current options
        currentOptions = []
        
        // Find next node
        guard let flow = currentFlow,
              let nextNode = flow.nodes.first(where: { $0.id == option.nextNode }) else {
            print("❌ ConversationalFlowViewModel: Next node not found: \(option.nextNode)")
            error = "Next node not found"
            return
        }
        
        currentNode = nextNode
        
        // Add a small delay before showing next messages
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.displayNode(nextNode)
        }
    }
    
    private func executeAction(_ action: String) {
        print("🔍 ConversationalFlowViewModel: Executing action: \(action)")
        
        switch action {
        case "breathing_exercise":
            addMessage("🫁 Let's breathe together...", isFromUser: false, messageType: .breathing)
            HapticService.shared.impact(.medium)
            
        case "grounding_exercise":
            addMessage("👁️ Look around you... what do you see?", isFromUser: false, messageType: .grounding)
            HapticService.shared.impact(.light)
            
        case "show_contacts":
            addMessage("📞 Here are your emergency contacts:", isFromUser: false, messageType: .contacts)
            HapticService.shared.impact(.light)
            
        case "save_techniques":
            addMessage("💾 Saving these techniques for you...", isFromUser: false)
            HapticService.shared.impact(.light)
            
        case "completion_haptic":
            HapticService.shared.flowCompleted()
            
        default:
            print("⚠️ ConversationalFlowViewModel: Unknown action: \(action)")
        }
    }
    
    private func addMessage(_ text: String, isFromUser: Bool, messageType: ConversationMessageType = .text) {
        let message = ChatMessage(content: text, isUser: isFromUser, messageType: messageType)
        
        withAnimation(.easeInOut(duration: 0.5)) {
            messages.append(message)
        }
        
        HapticService.shared.impact(.light)
        
        print("✅ ConversationalFlowViewModel: Added message: \(text)")
    }
    
    func resetFlow() {
        print("🔍 ConversationalFlowViewModel: Resetting flow")
        
        currentFlow = nil
        currentNode = nil
        messages = []
        currentOptions = []
        isFlowActive = false
        isLoading = false
        error = nil
        isTyping = false
    }
    
    // MARK: - Hardcoded fallback data for testing
    
    func loadHardcodedFlow() {
        print("🔍 ConversationalFlowViewModel: Loading hardcoded flow for testing")
        
        let hardcodedNode = ConversationalNode(
            id: "welcome",
            type: "conversation",
            messages: [
                "I'm here with you ❤️",
                "You're having a panic attack, and that's okay",
                "I'll help you through this, step by step"
            ],
            delay: 1.5,
            options: [
                ConversationOption(text: "I'm safe", nextNode: "breathing"),
                ConversationOption(text: "I need help", nextNode: "support")
            ],
            action: nil,
            nextNode: nil
        )
        
        let hardcodedMetadata = ConversationalFlowMetadata(
            author: "Compass AI Team",
            tags: ["panic", "support", "conversational", "caring"],
            difficulty: "easy",
            estimatedDuration: 180,
            emergencyLevel: "medium",
            requiresLocation: false,
            requiresContacts: false
        )
        
        let hardcodedFlow = ConversationalFlow(
            id: "panic_flow",
            type: "panic",
            title: "Panic Attack Support",
            description: "A caring friend to help you through panic attacks",
            version: "2.0",
            startNode: "welcome",
            nodes: [hardcodedNode],
            metadata: hardcodedMetadata
        )
        
        currentFlow = hardcodedFlow
        currentNode = hardcodedNode
        isFlowActive = true
        isLoading = false
        
        print("✅ ConversationalFlowViewModel: Loaded hardcoded flow")
        displayNode(hardcodedNode)
    }
} 