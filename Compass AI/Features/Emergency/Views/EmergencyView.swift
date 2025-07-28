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
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05)], 
                          startPoint: .top, 
                          endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // AI Chat Bar at top
                AIChatBar(
                    message: $aiMessage,
                    isListening: $isListening,
                    onSend: {
                        if !aiMessage.isEmpty {
                            // Analyze text for crisis keywords
                            if let crisisType = viewModel.analyzeTextForCrisis(aiMessage) {
                                showingCrisisType = crisisType
                            } else {
                                showingAIChat = true
                            }
                        }
                    },
                    onMicTap: {
                        isListening.toggle()
                        // TODO: Implement speech recognition
                    }
                )
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                // Crisis Cards Grid
                ScrollView {
                    VStack(spacing: 20) {
                        // Recent section (if any)
                        if !viewModel.recentCrises.isEmpty {
                            RecentCrisesSection(crises: viewModel.recentCrises) { crisis in
                                showingCrisisType = crisis
                            }
                        }
                        
                        // Main crisis grid
                        CrisisCardsGrid { crisis in
                            showingCrisisType = crisis
                        }
                        
                        // Smart suggestions based on time/location
                        if let suggestion = viewModel.smartSuggestion {
                            SmartSuggestionCard(suggestion: suggestion) {
                                showingCrisisType = suggestion.crisisType
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100) // Space for bottom bar
                }
            }
            
            // Bottom Navigation Bar
            VStack {
                Spacer()
                BottomNavigationBar(
                    onRights: { showingRights = true },
                    onContacts: { showingContacts = true },
                    onResources: { showingResources = true }
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
    
    var body: some View {
        HStack(spacing: 12) {
            // Mic button
            Button(action: onMicTap) {
                Image(systemName: isListening ? "stop.circle.fill" : "mic.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(isListening ? .red : .blue)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            
            // Text input
            HStack {
                TextField("What's happening? Tell me in your own words...", text: $message)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                
                if !message.isEmpty {
                    Button(action: onSend) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                    }
                    .padding(.trailing, 12)
                }
            }
            .background(Color.white)
            .cornerRadius(25)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .padding(.vertical, 8)
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
        VStack(spacing: 16) {
            Text("OR CHOOSE YOUR SITUATION")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .padding(.top, 8)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
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
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text(emoji)
                    .font(.system(size: 36))
                
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [color, color.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
            .scaleEffect(isAnimating ? 1.05 : 1.0)
            .animation(
                Animation.easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true),
                value: isAnimating
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Recent Crises Section
struct RecentCrisesSection: View {
    let crises: [CrisisType]
    let onCrisisTap: (CrisisType) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RECENT")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
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
            HStack(spacing: 8) {
                Text(crisisInfo.0)
                    .font(.system(size: 20))
                
                Text(crisisInfo.1)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(crisisInfo.2)
            .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Smart Suggestion Card
struct SmartSuggestionCard: View {
    let suggestion: SmartSuggestion
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: suggestion.icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(suggestion.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(suggestion.subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [.purple, .blue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Bottom Navigation Bar
struct BottomNavigationBar: View {
    let onRights: () -> Void
    let onContacts: () -> Void
    let onResources: () -> Void
    
    var body: some View {
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
        .background(Color(.systemBackground))
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
    }
}

// MARK: - Bottom Bar Button
struct BottomBarButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
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