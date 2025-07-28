import SwiftUI
import UIKit
import AVFoundation

struct FlowPlayerView: View {
    let crisisType: CrisisType
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = ConversationalFlowViewModel()
    @State private var showingPauseMenu = false
    @State private var showingVoiceToggle = false
    @State private var isVoiceEnabled = false
    @State private var synthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        ZStack {
            // Background
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
                    
                    if viewModel.isLoading {
                        VStack(spacing: 8) {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Loading guidance...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
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
                            // Welcome message
                            if viewModel.messages.isEmpty && !viewModel.isLoading {
                                WelcomeMessageView(crisisType: crisisType)
                                    .id("welcome")
                            }
                            
                            ForEach(viewModel.messages) { message in
                                ChatBubbleView(message: message)
                                    .id(message.id)
                            }
                            
                            // Typing indicator
                            if viewModel.isTyping {
                                TypingIndicatorView()
                                    .id("typing")
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            if let lastMessage = viewModel.messages.last {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: viewModel.isTyping) { isTyping in
                        if isTyping {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                proxy.scrollTo("typing", anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Options area
                if !viewModel.currentOptions.isEmpty {
                    OptionsView(options: viewModel.currentOptions) { option in
                        HapticService.shared.impact(.light)
                        viewModel.selectOption(option)
                    }
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
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("Try Again") {
                viewModel.error = nil
                startConversation()
            }
            Button("Use Fallback") {
                viewModel.error = nil
                viewModel.loadHardcodedFlow()
            }
            Button("Exit", role: .destructive) {
                dismiss()
            }
        } message: {
            if let error = viewModel.error {
                Text(error)
            }
        }
    }
    
    private func startConversation() {
        print("🔍 FlowPlayerView: Starting conversation for crisis type: \(crisisType)")
        
        Task {
            await viewModel.loadFlow(for: crisisType)
        }
    }
}

// MARK: - Options View
struct OptionsView: View {
    let options: [ConversationOption]
    let onOptionSelected: (ConversationOption) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Text("What would you like to do?")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 8)
            
            ForEach(options, id: \.text) { option in
                OptionButton(option: option) {
                    onOptionSelected(option)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .background(Color(.systemBackground).opacity(0.95))
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

// MARK: - Option Button
struct OptionButton: View {
    let option: ConversationOption
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(option.text)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Welcome Message View
struct WelcomeMessageView: View {
    let crisisType: CrisisType
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                    
                    Text("Compass AI")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                Text(welcomeMessage)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.systemGray6))
            )
            .frame(maxWidth: UIScreen.main.bounds.width * 0.85, alignment: .leading)
            
            Spacer()
        }
    }
    
    private var welcomeMessage: String {
        switch crisisType {
        case .panicAttack:
            return "Hi there! I'm here to help you through this panic attack. You're not alone, and we'll get through this together. Let me guide you step by step."
        case .domesticViolence:
            return "I'm here to help you stay safe. You deserve to feel secure and supported. Let me guide you through your options and resources."
        case .suicide:
            return "You matter, and your life has value. I'm here to listen and help you find support. You don't have to face this alone."
        case .medicalEmergency:
            return "I'm here to help you get the medical attention you need. Let me guide you through the next steps to ensure your safety."
        case .naturalDisaster:
            return "I'm here to help you stay safe during this emergency. Let me guide you through the immediate steps to protect yourself and others."
        case .bullying:
            return "I'm here to support you through this difficult situation. You deserve respect and kindness. Let me help you find ways to cope and get support."
        default:
            return "I'm here to help you through this difficult time. Let me guide you step by step."
        }
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
                    VStack(spacing: 8) {
                        Text(message.content)
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        BreathingAnimationView()
                            .frame(height: 100)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color(.systemGray6))
                    )
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)
                    
                case .grounding:
                    VStack(spacing: 8) {
                        Text(message.content)
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        GroundingChecklistView()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color(.systemGray6))
                    )
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)
                    
                case .contacts:
                    VStack(spacing: 8) {
                        Text(message.content)
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        EmergencyContactsQuickView()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color(.systemGray6))
                    )
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)
                    
                case .action:
                    Text(message.content)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color(.systemGray6))
                        )
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)
                }
            }
            
            if !message.isUser {
                Spacer()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: message.id)
    }
}

// MARK: - Typing Indicator View
struct TypingIndicatorView: View {
    @State private var dotOffset1: CGFloat = 0
    @State private var dotOffset2: CGFloat = 0
    @State private var dotOffset3: CGFloat = 0
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                        .offset(y: dotOffset1)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true)
                                .delay(0.0),
                            value: dotOffset1
                        )
                    
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                        .offset(y: dotOffset2)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true)
                                .delay(0.2),
                            value: dotOffset2
                        )
                    
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                        .offset(y: dotOffset3)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true)
                                .delay(0.4),
                            value: dotOffset3
                        )
                }
                
                Text("Compass AI is typing...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.systemGray6))
            )
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)
            
            Spacer()
        }
        .onAppear {
            dotOffset1 = -5
            dotOffset2 = -5
            dotOffset3 = -5
        }
    }
}

// MARK: - Preview
#Preview {
    FlowPlayerView(crisisType: .panicAttack)
} 