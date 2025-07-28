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
                    Button(action: { 
                        HapticService.shared.impact(.light)
                        showingPauseMenu = true 
                    }) {
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
                        Button(action: { 
                            HapticService.shared.impact(.light)
                            isVoiceEnabled.toggle() 
                        }) {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    } else {
                        Button(action: { 
                            HapticService.shared.impact(.light)
                            isVoiceEnabled.toggle() 
                        }) {
                            Image(systemName: "speaker.slash.fill")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground).opacity(0.9))
                
                // Chat messages area
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
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
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
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
                    let _ = print("🔍 FlowPlayerView: Showing \(viewModel.currentOptions.count) options")
                    OptionsView(options: viewModel.currentOptions) { option in
                        HapticService.shared.impact(.light)
                        viewModel.selectOption(option)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onAppear {
            print("🔍 FlowPlayerView: Appeared for crisis type: \(crisisType)")
            viewModel.loadFlow(for: crisisType)
        }
        .alert("Pause Conversation", isPresented: $showingPauseMenu) {
            Button("Resume") { }
            Button("Exit", role: .destructive) {
                HapticService.shared.impact(.medium)
                dismiss()
            }
        } message: {
            Text("Take a moment if you need to. I'll be here when you're ready.")
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("Try Again") {
                HapticService.shared.impact(.medium)
                viewModel.error = nil
                startConversation()
            }
            Button("Use Fallback") {
                HapticService.shared.impact(.medium)
                viewModel.error = nil
                viewModel.loadHardcodedFlow()
            }
            Button("Exit", role: .destructive) {
                HapticService.shared.impact(.medium)
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
        VStack(spacing: 16) {
            Text("What would you like to do?")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
                .padding(.top, 12)
            
            ForEach(options, id: \.text) { option in
                OptionButton(option: option) {
                    onOptionSelected(option)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .background(
            Color(.systemBackground)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: -4)
        )
    }
}

// MARK: - Option Button
struct OptionButton: View {
    let option: ConversationOption
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(option.text)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.blue)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1.5)
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Option: \(option.text)")
        .accessibilityHint("Double tap to select this option")
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Welcome Message View
struct WelcomeMessageView: View {
    let crisisType: CrisisType
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 12) {
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
                    .font(.system(size: 18))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
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
                        .font(.system(size: 18))
                        .foregroundColor(message.isUser ? .white : .primary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(message.isUser ? Color.blue : Color(.systemGray6))
                        )
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.isUser ? .trailing : .leading)
                        
                case .breathing:
                    VStack(spacing: 12) {
                        Text(message.content)
                            .font(.system(size: 18))
                            .foregroundColor(.primary)
                        
                        BreathingAnimationView()
                            .frame(height: 120)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray6))
                    )
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)
                    
                case .grounding:
                    VStack(spacing: 12) {
                        Text(message.content)
                            .font(.system(size: 18))
                            .foregroundColor(.primary)
                        
                        GroundingChecklistView()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray6))
                    )
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)
                    
                case .contacts:
                    VStack(spacing: 12) {
                        Text(message.content)
                            .font(.system(size: 18))
                            .foregroundColor(.primary)
                        
                        EmergencyContactsQuickView()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray6))
                    )
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)
                    
                case .action:
                    Text(message.content)
                        .font(.system(size: 18))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
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
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 10, height: 10)
                        .offset(y: dotOffset1)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true)
                                .delay(0.0),
                            value: dotOffset1
                        )
                    
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 10, height: 10)
                        .offset(y: dotOffset2)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true)
                                .delay(0.2),
                            value: dotOffset2
                        )
                    
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 10, height: 10)
                        .offset(y: dotOffset3)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true)
                                .delay(0.4),
                            value: dotOffset3
                        )
                }
                
                Text("Compass AI is typing...")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray6))
            )
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)
            
            Spacer()
        }
        .onAppear {
            dotOffset1 = -6
            dotOffset2 = -6
            dotOffset3 = -6
        }
    }
}

// MARK: - Preview
#Preview {
    FlowPlayerView(crisisType: .panicAttack)
} 