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
    
    func loadFlow(for crisisType: CrisisType) {
        print("🔍 ConversationalFlowViewModel: Loading flow for crisis type: \(crisisType)")
        isLoading = true
        error = nil
        messages = []
        currentOptions = []
        
        Task {
            do {
                // Convert CrisisType to FlowType
                let flowType = convertCrisisTypeToFlowType(crisisType)
                print("🔍 ConversationalFlowViewModel: Converted to FlowType: \(flowType.rawValue)")
                
                // Load the conversational flow
                let flow = try await flowRepository.loadConversationalFlow(flowType)
                
                await MainActor.run {
                    print("🔍 ConversationalFlowViewModel: Successfully loaded flow: \(flow.title)")
                    print("🔍 ConversationalFlowViewModel: Flow has \(flow.nodes.count) nodes")
                    print("🔍 ConversationalFlowViewModel: Start node: \(flow.startNode)")
                    print("🔍 ConversationalFlowViewModel: Node IDs: \(flow.nodes.map { $0.id })")
                    
                    self.currentFlow = flow
                    self.isLoading = false
                    self.isFlowActive = true
                    
                    // Start the flow
                    self.startFlow()
                }
            } catch {
                await MainActor.run {
                    print("❌ ConversationalFlowViewModel: Failed to load flow: \(error)")
                    self.error = error.localizedDescription
                    self.isLoading = false
                    
                    // Load hardcoded fallback
                    print("🔄 ConversationalFlowViewModel: Loading hardcoded fallback")
                    self.loadHardcodedFlow()
                }
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
        
        // Clear current options first
        currentOptions = []
        
        // Add messages one by one with typing animation
        for (index, message) in node.messages.enumerated() {
            let delay = Double(index) * 2.0 // Increased delay for more natural conversation
            
            let workItem = DispatchWorkItem {
                self.isTyping = true
                
                let innerWorkItem = DispatchWorkItem {
                    let chatMessage = ChatMessage(
                        content: message,
                        isUser: false,
                        messageType: .text
                    )
                    
                    self.messages.append(chatMessage)
                    self.isTyping = false
                    
                    // If this is the last message, show options
                    if index == node.messages.count - 1 {
                        print("🔍 ConversationalFlowViewModel: Last message displayed, checking for options")
                        if let options = node.options, !options.isEmpty {
                            print("🔍 ConversationalFlowViewModel: Setting \(options.count) options")
                            DispatchQueue.main.async {
                                self.currentOptions = options
                            }
                        } else if let nextNode = node.nextNode {
                            print("🔍 ConversationalFlowViewModel: No options, moving to next node: \(nextNode)")
                            // Auto-progress to next node if no options
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: DispatchWorkItem {
                                self.moveToNode(nextNode)
                            })
                        }
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: innerWorkItem)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
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
    
    private func moveToNode(_ nodeId: String) {
        print("🔍 ConversationalFlowViewModel: Moving to node: \(nodeId)")
        
        guard let flow = currentFlow else {
            print("❌ ConversationalFlowViewModel: No current flow available")
            return
        }
        
        guard let node = flow.nodes.first(where: { $0.id == nodeId }) else {
            print("❌ ConversationalFlowViewModel: Node not found: \(nodeId)")
            return
        }
        
        print("🔍 ConversationalFlowViewModel: Found node: \(node.id)")
        print("🔍 ConversationalFlowViewModel: Node type: \(node.type)")
        print("🔍 ConversationalFlowViewModel: Node has \(node.messages.count) messages")
        print("🔍 ConversationalFlowViewModel: Node has \(node.options?.count ?? 0) options")
        print("🔍 ConversationalFlowViewModel: Node has nextNode: \(node.nextNode ?? "none")")
        
        if let options = node.options {
            print("🔍 ConversationalFlowViewModel: Options are:")
            for option in options {
                print("  - \(option.text) -> \(option.nextNode)")
            }
        }
        
        currentNode = node
        displayNode(node)
    }
    
    // MARK: - Interactive Technique Handling
    
    func handleTechniqueComplete() {
        print("🔍 ConversationalFlowViewModel: Technique completed")
        
        guard let currentNode = currentNode else {
            print("❌ ConversationalFlowViewModel: No current node for technique completion")
            return
        }
        
        // Add completion message
        addMessage("Exercise completed", isFromUser: false)
        
        // Move to next node if specified
        if let nextNode = currentNode.nextNode {
            moveToNode(nextNode)
        } else {
            // Show options if available
            if let options = currentNode.options, !options.isEmpty {
                DispatchQueue.main.async {
                    self.currentOptions = options
                }
            }
        }
    }
    
    // MARK: - Panic Assessment Flow Support
    
    func loadPanicAssessmentFlow() {
        print("🔍 ConversationalFlowViewModel: Loading panic assessment flow")
        
        // Load the new panic assessment flow
        Task {
            do {
                let flow = try await flowRepository.loadConversationalFlow(.panic)
                await MainActor.run {
                    self.currentFlow = flow
                    self.isLoading = false
                    self.isFlowActive = true
                    self.startFlow()
                }
            } catch {
                await MainActor.run {
                    print("❌ ConversationalFlowViewModel: Failed to load panic assessment flow: \(error)")
                    self.loadHardcodedFlow()
                }
            }
        }
    }
} 