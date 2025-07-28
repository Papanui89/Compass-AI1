import SwiftUI

struct AIChatView: View {
    @StateObject private var viewModel = AIChatViewModel()
    @State private var userInput = ""
    @State private var isListening = false
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Chat messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            // Welcome message
                            ChatBubble(
                                message: "I'm here to help. Tell me what's happening and I'll guide you through it.",
                                isUser: false,
                                isTyping: false
                            )
                            
                            // Chat history
                            ForEach(viewModel.messages) { message in
                                ChatBubble(
                                    message: message.content,
                                    isUser: message.isUser,
                                    isTyping: false
                                )
                            }
                            
                            // Typing indicator
                            if viewModel.isAITyping {
                                ChatBubble(
                                    message: "",
                                    isUser: false,
                                    isTyping: true
                                )
                            }
                        }
                        .padding()
                        .onChange(of: viewModel.messages.count) { _ in
                            withAnimation {
                                proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Input area
                VStack(spacing: 0) {
                    Divider()
                    
                    HStack(spacing: 12) {
                        // Voice input button
                        Button(action: {
                            isListening.toggle()
                            if isListening {
                                viewModel.startListening()
                            } else {
                                viewModel.stopListening()
                            }
                        }) {
                            Image(systemName: isListening ? "mic.fill" : "mic")
                                .font(.title2)
                                .foregroundColor(isListening ? .red : .blue)
                                .animation(.easeInOut, value: isListening)
                        }
                        
                        // Text input
                        TextField("Type or speak your situation...", text: $userInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($isInputFocused)
                            .onSubmit {
                                sendMessage()
                            }
                        
                        // Send button
                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title)
                                .foregroundColor(userInput.isEmpty ? .gray : .blue)
                        }
                        .disabled(userInput.isEmpty)
                    }
                    .padding()
                }
                .background(Color(.systemBackground))
            }
            .navigationTitle("Crisis Helper")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Emergency") {
                        viewModel.triggerEmergencyMode()
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .onAppear {
            isInputFocused = true
        }
    }
    
    private func sendMessage() {
        guard !userInput.isEmpty else { return }
        viewModel.sendMessage(userInput)
        userInput = ""
    }
}

// Chat Bubble Component
struct ChatBubble: View {
    let message: String
    let isUser: Bool
    let isTyping: Bool
    
    var body: some View {
        HStack {
            if isUser { Spacer() }
            
            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                if isTyping {
                    TypingIndicator()
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray5))
                        .cornerRadius(20)
                } else {
                    Text(message)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(isUser ? Color.blue : Color(.systemGray5))
                        .foregroundColor(isUser ? .white : .primary)
                        .cornerRadius(20)
                }
            }
            
            if !isUser { Spacer() }
        }
    }
}

// Typing Indicator
struct TypingIndicator: View {
    @State private var animatingDot = 0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.gray)
                    .frame(width: 8, height: 8)
                    .scaleEffect(animatingDot == index ? 1.3 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: animatingDot
                    )
            }
        }
        .onAppear {
            animatingDot = 0
        }
    }
}

#Preview {
    AIChatView()
} 