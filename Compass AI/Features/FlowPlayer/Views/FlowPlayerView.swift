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
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
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
                            ForEach(viewModel.messages) { message in
                                ChatBubbleView(message: message)
                                    .id(message.id)
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
                }
                
                // Options area
                if !viewModel.currentOptions.isEmpty {
                    VStack(spacing: 12) {
                        ForEach(viewModel.currentOptions, id: \.text) { option in
                            Button(action: {
                                viewModel.selectOption(option)
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



// MARK: - Preview
#Preview {
    FlowPlayerView(crisisType: .panicAttack)
} 