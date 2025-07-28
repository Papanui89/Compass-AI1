import SwiftUI

struct EmergencyView: View {
    @EnvironmentObject private var viewModel: EmergencyViewModel
    @State private var showingCrisisType: CrisisType?
    @State private var showingPanicMode = false
    @State private var showingAIChat = false
    @State private var showingRights = false
    @State private var showingContacts = false
    @State private var showingResources = false
    @State private var aiMessage = ""
    @State private var isListening = false
    @State private var isLoadingFlow = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background gradient
            LinearGradient(colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05)], 
                          startPoint: .top, 
                          endPoint: .bottom)
                .ignoresSafeArea()
            
            // Main scrollable content
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 24) {
                    // AI Chat Bar at top - Hero Feature
                    AIChatBar(
                        message: $aiMessage,
                        isListening: $isListening,
                        onSend: {
                            if !aiMessage.isEmpty {
                                HapticService.shared.impact(.medium)
                                // Analyze text for crisis keywords
                                if let crisisType = viewModel.analyzeTextForCrisis(aiMessage) {
                                    showingCrisisType = crisisType
                                } else {
                                    showingAIChat = true
                                }
                            }
                        },
                        onMicTap: {
                            HapticService.shared.impact(.light)
                            isListening.toggle()
                            // TODO: Implement speech recognition
                        }
                    )
                    .padding(.horizontal)
                    
                    // Recent section (if any)
                    if !viewModel.recentCrises.isEmpty {
                        RecentCrisesSection(crises: viewModel.recentCrises) { crisis in
                            HapticService.shared.impact(.medium)
                            showingCrisisType = crisis
                        }
                        .padding(.horizontal)
                    }
                    
                    // Main crisis grid
                    CrisisCardsGrid { crisis in
                        HapticService.shared.impact(.medium)
                        showingCrisisType = crisis
                    }
                    .padding(.horizontal)
                    
                    // Smart suggestions based on time/location
                    if let suggestion = viewModel.smartSuggestion {
                        SmartSuggestionCard(suggestion: suggestion) {
                            HapticService.shared.impact(.medium)
                            showingCrisisType = suggestion.crisisType
                        }
                        .padding(.horizontal)
                    }
                    
                    // CRITICAL: Add bottom padding for bottom bar
                    Color.clear
                        .frame(height: 120)
                }
                .padding(.top)
                .background(GeometryReader { geo in
                    Color.clear.onAppear {
                        print("Content height: \(geo.size.height)")
                    }
                })
            }
            
            // Bottom navigation (floating)
            VStack {
                Spacer()
                BottomNavigationBar(
                    onRights: { 
                        HapticService.shared.impact(.light)
                        showingRights = true 
                    },
                    onContacts: { 
                        HapticService.shared.impact(.light)
                        showingContacts = true 
                    },
                    onResources: { 
                        HapticService.shared.impact(.light)
                        showingResources = true 
                    }
                )
                .background(.ultraThinMaterial) // Translucent background
                .background(Color(.systemBackground).opacity(0.9))
                .shadow(radius: 10, y: -5) // Elevation shadow
            }
        }
        .navigationBarHidden(true)
        .sheet(item: $showingCrisisType) { crisis in
            FlowPlayerView(crisisType: crisis)
        }
        .sheet(isPresented: $showingAIChat) {
            AIChatView()
        }
        .fullScreenCover(isPresented: $showingPanicMode) {
            PanicModeView()
        }
        .sheet(isPresented: $showingRights) {
            RightsView()
        }
        .sheet(isPresented: $showingContacts) {
            EmergencyContactsView()
        }
        .sheet(isPresented: $showingResources) {
            ResourcesView()
        }
        .onAppear {
            viewModel.loadRecentCrises()
            viewModel.generateSmartSuggestion()
        }
    }
}

// MARK: - AI Chat Bar Component
struct AIChatBar: View {
    @Binding var message: String
    @Binding var isListening: Bool
    let onSend: () -> Void
    let onMicTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Hero AI Chat Section
            VStack(spacing: 28) {
                // Header with AI label and title
                HStack(spacing: 18) {
                    HStack {
                        Text("AI")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue)
                            .cornerRadius(8)
                        
                        Text("What's happening? Talk to me...")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                }
                
                // Chat input area
                HStack(spacing: 24) {
                    // Mic button
                    Button(action: onMicTap) {
                        Image(systemName: isListening ? "stop.circle.fill" : "mic.circle.fill")
                            .font(.system(size: 56, weight: .medium))
                            .foregroundColor(isListening ? .red : .white)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.25))
                                    .frame(width: 76, height: 76)
                            )
                            .frame(width: 76, height: 76)
                            .scaleEffect(isListening ? 1.1 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isListening)
                    }
                    .accessibilityLabel(isListening ? "Stop recording" : "Start voice recording")
                    
                    // Text input
                    HStack {
                        TextField("Type your message here...", text: $message)
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal, 28)
                            .padding(.vertical, 24)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(26)
                        
                        if !message.isEmpty {
                            Button(action: onSend) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 40, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .accessibilityLabel("Send message")
                            .padding(.trailing, 14)
                        }
                    }
                }
            }
            .padding(36)
            .background(
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.15),
                        Color.purple.opacity(0.15)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(30)
            .shadow(
                color: Color.purple.opacity(0.4),
                radius: 18,
                x: 0,
                y: 10
            )
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
            )
            
            // Divider with "OR" text
            HStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
                
                Text("OR")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
            }
            .padding(.vertical, 24)
        }
    }
}

// MARK: - Crisis Cards Grid
struct CrisisCardsGrid: View {
    let onCrisisTap: (CrisisType) -> Void
    
    private let crisisData: [(CrisisType, String, String, Color)] = [
        (.panicAttack, "😰", "PANIC ATTACK", .orange),
        (.bullying, "🛡️", "GETTING BULLIED", .blue),
        (.suicide, "💔", "SUICIDAL THOUGHTS", .red),
        (.harassment, "🚨", "COPS/COPS STOP", .purple),
        (.medicalEmergency, "🏥", "MEDICAL EMERGENCY", .red),
        (.domesticViolence, "🏠", "UNSAFE AT HOME", .red)
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("CHOOSE YOUR SITUATION")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.top, 8)
            
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ],
                spacing: 16
            ) {
                ForEach(crisisData, id: \.0) { crisis in
                    CrisisCard(
                        emoji: crisis.1,
                        title: crisis.2,
                        color: crisis.3
                    ) {
                        onCrisisTap(crisis.0)
                    }
                }
            }
        }
    }
}

// MARK: - Crisis Card Component
struct CrisisCard: View {
    let emoji: String
    let title: String
    let color: Color
    let action: () -> Void
    
    @State private var isAnimating = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text(emoji)
                    .font(.system(size: 36))
                    .scaleEffect(isAnimating ? 1.08 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 2.5)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(minHeight: 100)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .background(
                LinearGradient(
                    colors: [color, color.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(20)
            .shadow(
                color: color.opacity(0.4),
                radius: 8,
                x: 0,
                y: 4
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(title) - Tap for help")
        .accessibilityHint("Double tap to get help for \(title.lowercased())")
        .onAppear {
            isAnimating = true
        }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Recent Crises Section
struct RecentCrisesSection: View {
    let crises: [CrisisType]
    let onCrisisTap: (CrisisType) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("RECENT")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(crises, id: \.self) { crisis in
                        RecentCrisisCard(crisis: crisis) {
                            onCrisisTap(crisis)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

// MARK: - Recent Crisis Card
struct RecentCrisisCard: View {
    let crisis: CrisisType
    let action: () -> Void
    
    @State private var isPressed = false
    
    private var crisisInfo: (String, String, Color) {
        switch crisis {
        case .panicAttack: return ("😰", "PANIC ATTACK", .orange)
        case .bullying: return ("🛡️", "BULLIED", .blue)
        case .suicide: return ("💔", "SUICIDAL THOUGHTS", .red)
        case .harassment: return ("🚨", "COPS", .purple)
        case .medicalEmergency: return ("🏥", "MEDICAL", .red)
        case .domesticViolence: return ("🏠", "UNSAFE", .red)
        case .mentalHealth: return ("🧠", "MENTAL HEALTH", .blue)
        case .substanceAbuse: return ("💊", "SUBSTANCE", .purple)
        case .naturalDisaster: return ("🌪️", "DISASTER", .gray)
        case .violence: return ("⚔️", "VIOLENCE", .orange)
        case .abuse: return ("⚠️", "ABUSE", .yellow)
        case .other: return ("❓", "OTHER", .secondary)
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(crisisInfo.0)
                    .font(.system(size: 20))
                
                Text(crisisInfo.1)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [crisisInfo.2, crisisInfo.2.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(20)
            .shadow(color: crisisInfo.2.opacity(0.4), radius: 5, x: 0, y: 2)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Recent: \(crisisInfo.1) - Tap for help")
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Smart Suggestion Card
struct SmartSuggestionCard: View {
    let suggestion: SmartSuggestion
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Image(systemName: suggestion.icon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(suggestion.title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(suggestion.subtitle)
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(24)
            .background(
                LinearGradient(
                    colors: [.purple, .blue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(24)
            .shadow(color: .purple.opacity(0.4), radius: 10, x: 0, y: 5)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Suggestion: \(suggestion.title) - \(suggestion.subtitle)")
        .accessibilityHint("Double tap to get help for \(suggestion.title.lowercased())")
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Bottom Navigation Bar
struct BottomNavigationBar: View {
    let onRights: () -> Void
    let onContacts: () -> Void
    let onResources: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Separator line
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
            
            // Bottom Navigation Bar
            HStack(spacing: 0) {
                BottomBarButton(
                    icon: "doc.text",
                    title: "Rights",
                    action: onRights
                )
                
                BottomBarButton(
                    icon: "person.2",
                    title: "Contacts",
                    action: onContacts
                )
                
                BottomBarButton(
                    icon: "folder",
                    title: "Resources",
                    action: onResources
                )
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 12) // Extra padding for home indicator
            .background(
                Color(.systemBackground)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: -4)
            )
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Bottom Bar Button
struct BottomBarButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.blue)
                    .scaleEffect(isPressed ? 0.9 : 1.0)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(title) - Tap to open")
        .accessibilityHint("Double tap to open \(title.lowercased())")
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Smart Suggestion Model
struct SmartSuggestion {
    let title: String
    let subtitle: String
    let icon: String
    let crisisType: CrisisType
}

// MARK: - Preview
struct EmergencyView_Previews: PreviewProvider {
    static var previews: some View {
        EmergencyView()
    }
} 