import SwiftUI
import UIKit
import AVFoundation

struct FlowPlayerView: View {
    let crisisType: CrisisType
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = ConversationalFlowViewModel()
    @State private var messages: [ChatMessage] = []
    @State private var showingOptions = false
    @State private var currentOptions: [ConversationOption] = []
    @State private var isTyping = false
    @State private var currentMessageIndex = 0
    @State private var showingPauseMenu = false
    @State private var showingVoiceToggle = false
    @State private var isVoiceEnabled = false
    @State private var synthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        ZStack {
            // Soft gradient background
            LinearGradient(
                colors: [
                    crisisType.color.opacity(0.1),
                    Color(.systemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top navigation bar
                HStack {
                    Button(action: { showingPauseMenu = true }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if isVoiceEnabled {
                        Button(action: { isVoiceEnabled.toggle() }) {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    } else {
                        Button(action: { isVoiceEnabled.toggle() }) {
                            Image(systemName: "speaker.slash.fill")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground).opacity(0.8))
                
                // Chat messages area
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(messages) { message in
                                ChatBubbleView(message: message)
                                    .id(message.id)
                            }
                            
                            // Typing indicator
                            if isTyping {
                                TypingIndicatorView()
                                    .id("typing")
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                    .onChange(of: messages.count) { _ in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            if let lastMessage = messages.last {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Options area
                if showingOptions && !currentOptions.isEmpty {
                    VStack(spacing: 12) {
                        ForEach(currentOptions, id: \.text) { option in
                            Button(action: {
                                selectOption(option)
                            }) {
                                Text(option.text)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemGray6))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .background(Color(.systemBackground).opacity(0.9))
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onAppear {
            startConversation()
        }
        .alert("Pause Conversation", isPresented: $showingPauseMenu) {
            Button("Resume") { }
            Button("Exit", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("Take a moment if you need to. I'll be here when you're ready.")
        }
    }
    
    private func startConversation() {
        Task {
            await loadConversationalFlow()
            await displayNextNode()
        }
    }
    
    private func loadConversationalFlow() async {
        // Load the conversational flow from JSON
        guard let url = Bundle.main.url(forResource: "panic", withExtension: "json", subdirectory: "Resources/Flows") else {
            addMessage("I'm here to help you through this.", isFromUser: false)
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let flow = try JSONDecoder().decode(ConversationalFlow.self, from: data)
            viewModel.setFlow(flow)
        } catch {
            addMessage("I'm here to help you through this.", isFromUser: false)
        }
    }
    
    private func displayNextNode() async {
        guard let currentNode = viewModel.getCurrentNode() else { return }
        
        // Display messages one by one with typing animation
        for (index, message) in currentNode.messages.enumerated() {
            if index > 0 {
                try? await Task.sleep(nanoseconds: UInt64(currentNode.delay ?? 1.0) * 1_000_000_000)
            }
            
            await MainActor.run {
                addMessage(message, isFromUser: false)
                if isVoiceEnabled {
                    speakMessage(message)
                }
            }
        }
        
        // Show options if available
        if let options = currentNode.options {
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentOptions = options
                    showingOptions = true
                }
            }
        } else if let action = currentNode.action {
            await executeAction(action)
            if let nextNode = currentNode.nextNode {
                viewModel.setCurrentNode(nextNode)
                await displayNextNode()
            }
        } else if let nextNode = currentNode.nextNode {
            viewModel.setCurrentNode(nextNode)
            await displayNextNode()
        }
    }
    
    private func selectOption(_ option: ConversationOption) {
        // Add user's choice to chat
        addMessage(option.text, isFromUser: true)
        
        // Hide options
        withAnimation(.easeInOut(duration: 0.3)) {
            showingOptions = false
            currentOptions = []
        }
        
        // Move to next node
        viewModel.setCurrentNode(option.nextNode)
        
        // Continue conversation
        Task {
            await displayNextNode()
        }
    }
    
    private func executeAction(_ action: String) async {
        switch action {
        case "breathing_exercise":
            await MainActor.run {
                addMessage("Let's breathe together...", isFromUser: false, messageType: .breathing)
            }
            // Show breathing animation
            try? await Task.sleep(nanoseconds: 30_000_000_000) // 30 seconds
            
        case "grounding_exercise":
            await MainActor.run {
                addMessage("Look around you... what do you see?", isFromUser: false, messageType: .grounding)
            }
            // Show grounding exercise
            try? await Task.sleep(nanoseconds: 15_000_000_000) // 15 seconds
            
        case "show_contacts":
            await MainActor.run {
                addMessage("Who would you like to call?", isFromUser: false, messageType: .contacts)
            }
            // Show contacts
            
        case "save_techniques":
            await MainActor.run {
                addMessage("I've saved these techniques for you!", isFromUser: false)
            }
            
        case "completion_haptic":
            HapticService.shared.flowCompleted()
            
        default:
            break
        }
    }
    
    private func addMessage(_ text: String, isFromUser: Bool, messageType: ConversationMessageType = .text) {
        let message = ChatMessage(content: text, isUser: isFromUser, messageType: messageType)
        withAnimation(.easeInOut(duration: 0.3)) {
            messages.append(message)
        }
        HapticService.shared.impact(.light)
    }
    
    private func speakMessage(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.1
        utterance.volume = 0.8
        synthesizer.speak(utterance)
    }
}

// MARK: - Chat Bubble View
struct ChatBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                switch message.messageType {
                case .text:
                    Text(message.content)
                        .font(.body)
                        .foregroundColor(message.isUser ? .white : .primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(message.isUser ? Color.blue : Color(.systemGray6))
                        )
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.isUser ? .trailing : .leading)
                        
                case .breathing:
                    BreathingMessageView(text: message.content)
                    
                case .grounding:
                    GroundingMessageView(text: message.content)
                    
                case .contacts:
                    ContactsMessageView(text: message.content)
                    
                case .action:
                    ActionMessageView(text: message.content)
                }
            }
            
            if !message.isUser {
                Spacer()
            }
        }
    }
}

// MARK: - Typing Indicator
struct TypingIndicatorView: View {
    @State private var dotOffset: CGFloat = 0
    
    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                        .offset(y: dotOffset)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: dotOffset
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.systemGray6))
            )
            
            Spacer()
        }
        .onAppear {
            dotOffset = -5
        }
    }
}

// MARK: - Special Message Views
struct BreathingMessageView: View {
    let text: String
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 12) {
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color(.systemGray6))
                )
            
            // Animated breathing circle
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .scaleEffect(scale)
                    .animation(
                        Animation.easeInOut(duration: 4)
                            .repeatForever(autoreverses: true),
                        value: scale
                    )
            }
        }
        .onAppear {
            scale = 1.5
        }
    }
}

struct GroundingMessageView: View {
    let text: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color(.systemGray6))
                )
            
            Text("👁️ Look around • 🖐️ Touch something • 👂 Listen")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct ContactsMessageView: View {
    let text: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color(.systemGray6))
                )
            
            Text("📞 Tap to call someone you trust")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct ActionMessageView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.body)
            .foregroundColor(.primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.green.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                    )
            )
    }
}

// MARK: - View Model
class ConversationalFlowViewModel: ObservableObject {
    private var flow: ConversationalFlow?
    private var currentNodeId: String?
    
    func setFlow(_ flow: ConversationalFlow) {
        self.flow = flow
        self.currentNodeId = flow.startNode
    }
    
    func getCurrentNode() -> ConversationalNode? {
        guard let flow = flow, let currentNodeId = currentNodeId else { return nil }
        return flow.nodes.first { $0.id == currentNodeId }
    }
    
    func setCurrentNode(_ nodeId: String) {
        self.currentNodeId = nodeId
    }
}

// MARK: - Preview
#Preview {
    FlowPlayerView(crisisType: .panicAttack)
} 