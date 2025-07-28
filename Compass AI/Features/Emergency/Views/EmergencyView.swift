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
        ZStack {
            // Background gradient
            LinearGradient(colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05)], 
                          startPoint: .top, 
                          endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
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
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Crisis Cards Grid
                ScrollView {
                    VStack(spacing: 24) {
                        // Recent section (if any)
                        if !viewModel.recentCrises.isEmpty {
                            RecentCrisesSection(crises: viewModel.recentCrises) { crisis in
                                HapticService.shared.impact(.medium)
                                showingCrisisType = crisis
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Main crisis grid
                        CrisisCardsGrid { crisis in
                            HapticService.shared.impact(.medium)
                            showingCrisisType = crisis
                        }
                        .padding(.horizontal, 20)
                        
                        // Smart suggestions based on time/location
                        if let suggestion = viewModel.smartSuggestion {
                            SmartSuggestionCard(suggestion: suggestion) {
                                HapticService.shared.impact(.medium)
                                showingCrisisType = suggestion.crisisType
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Bottom spacing for navigation bar
                        Spacer(minLength: 140)
                    }
                    .padding(.top, 8)
                }
            }
            
            // Bottom Navigation Bar
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
    
    @State private var isPulsing = false
    @State private var isGlowing = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Hero AI Chat Section
            VStack(spacing: 20) {
                // Header with icon and title
                HStack(spacing: 16) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.white)
                        .scaleEffect(isPulsing ? 1.15 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 2.0)
                                .repeatForever(autoreverses: true),
                            value: isPulsing
                        )
                    
                    Text("What's happening? Talk to me...")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                
                // Chat input area
                HStack(spacing: 20) {
                    // Mic button
                    Button(action: onMicTap) {
                        Image(systemName: isListening ? "stop.circle.fill" : "mic.circle.fill")
                            .font(.system(size: 52, weight: .medium))
                            .foregroundColor(isListening ? .red : .white)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.25))
                                    .frame(width: 70, height: 70)
                            )
                            .frame(width: 70, height: 70)
                            .scaleEffect(isListening ? 1.1 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isListening)
                    }
                    .accessibilityLabel(isListening ? "Stop recording" : "Start voice recording")
                    
                    // Text input
                    HStack {
                        TextField("Type your message here...", text: $message)
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal, 24)
                            .padding(.vertical, 20)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(24)
                        
                        if !message.isEmpty {
                            Button(action: onSend) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 36, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .accessibilityLabel("Send message")
                            .padding(.trailing, 12)
                        }
                    }
                }
            }
            .padding(28)
            .background(
                LinearGradient(
                    colors: [
                        Color.purple.opacity(0.95),
                        Color.blue.opacity(0.85)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(28)
            .shadow(
                color: Color.purple.opacity(0.4),
                radius: 16,
                x: 0,
                y: 8
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
            )
            .scaleEffect(isGlowing ? 1.02 : 1.0)
            .animation(
                Animation.easeInOut(duration: 3.0)
                    .repeatForever(autoreverses: true),
                value: isGlowing
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
        .onAppear {
            isPulsing = true
            isGlowing = true
        }
    }
}

// MARK: - Crisis Cards Grid
struct CrisisCardsGrid: View {
    let onCrisisTap: (CrisisType) -> Void
    
    private let crisisData: [(CrisisType, String, String, Color)] = [
        (.panicAttack, "😰", "FREAKING OUT", .orange),
        (.bullying, "🛡️", "GETTING BULLIED", .blue),
        (.suicide, "💔", "WANT TO DIE", .red),
        (.harassment, "🚨", "COPS/COPS STOP", .purple),
        (.medicalEmergency, "🏥", "MEDICAL EMERGENCY", .red),
        (.domesticViolence, "🏠", "UNSAFE AT HOME", .red)
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            Text("CHOOSE YOUR SITUATION")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.top, 12)
            
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 20),
                    GridItem(.flexible(), spacing: 20)
                ],
                spacing: 20
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
            VStack(spacing: 20) {
                Text(emoji)
                    .font(.system(size: 48))
                    .scaleEffect(isAnimating ? 1.08 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 2.5)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
            }
            .frame(minHeight: 140)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .padding(.horizontal, 20)
            .background(
                LinearGradient(
                    colors: [color, color.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(24)
            .shadow(
                color: color.opacity(0.4),
                radius: 12,
                x: 0,
                y: 6
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
        case .panicAttack: return ("😰", "FREAKING OUT", .orange)
        case .bullying: return ("🛡️", "BULLIED", .blue)
        case .suicide: return ("💔", "WANT TO DIE", .red)
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
            HStack(spacing: 12) {
                Text(crisisInfo.0)
                    .font(.system(size: 24))
                
                Text(crisisInfo.1)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [crisisInfo.2, crisisInfo.2.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(24)
            .shadow(color: crisisInfo.2.opacity(0.4), radius: 6, x: 0, y: 3)
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
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 40) // Extra padding for home indicator
            .background(
                Color(.systemBackground)
                    .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: -6)
            )
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 0)
        }
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
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(.blue)
                    .scaleEffect(isPressed ? 0.9 : 1.0)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
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