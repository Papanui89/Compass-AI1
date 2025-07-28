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
        
        // Start displaying messages
        displayNode(startNode)
    }
    
    private func displayNode(_ node: ConversationalNode) {
        print("🔍 ConversationalFlowViewModel: Displaying node: \(node.id)")
        
        // Add messages one by one with delay
        for (index, message) in node.messages.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 1.5) {
                self.addMessage(message, isFromUser: false)
            }
        }
        
        // Show options after messages (if any)
        if let options = node.options {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(node.messages.count) * 1.5) {
                self.currentOptions = options
                print("✅ ConversationalFlowViewModel: Showing \(options.count) options")
            }
        }
        
        // Execute action if specified
        if let action = node.action {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(node.messages.count) * 1.5) {
                self.executeAction(action)
            }
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
        displayNode(nextNode)
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
        
        withAnimation(.easeInOut(duration: 0.3)) {
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
        
        let hardcodedFlow = ConversationalFlow(
            id: "panic_flow",
            type: "panic",
            title: "Panic Attack Support",
            description: "A caring friend to help you through panic attacks",
            version: "2.0",
            startNode: "welcome",
            nodes: [hardcodedNode],
            metadata: FlowMetadata()
        )
        
        currentFlow = hardcodedFlow
        currentNode = hardcodedNode
        isFlowActive = true
        isLoading = false
        
        print("✅ ConversationalFlowViewModel: Loaded hardcoded flow")
        displayNode(hardcodedNode)
    }
} 