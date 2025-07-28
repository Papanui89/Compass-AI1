import SwiftUI

struct EmergencyView: View {
    @StateObject private var viewModel = EmergencyViewModel()
    @State private var showingCrisisType: CrisisType?
    @State private var showingPanicMode = false
    @State private var showingAIChat = false
    @State private var showingRights = false
    @State private var showingContacts = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)], 
                          startPoint: .top, 
                          endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Panic Button at top
                PanicButton {
                    showingPanicMode = true
                    HapticService.shared.impact(.heavy)
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Main 3-Tap Options
                VStack(spacing: 25) {
                    // What to Do
                    EmergencyOptionButton(
                        title: "What to Do",
                        subtitle: "Step-by-step help",
                        icon: "figure.run",
                        color: .purple
                    ) {
                        showingCrisisType = .panicAttack // Will expand to selection
                    }
                    
                    // What to Say
                    EmergencyOptionButton(
                        title: "What to Say", 
                        subtitle: "Your rights & scripts",
                        icon: "bubble.left.fill",
                        color: .blue
                    ) {
                        showingRights = true
                    }
                    
                    // Who to Call
                    EmergencyOptionButton(
                        title: "Who to Call",
                        subtitle: "Emergency contacts",
                        icon: "phone.fill",
                        color: .green
                    ) {
                        showingContacts = true
                    }
                }
                .padding(.horizontal, 20)
                
                // AI Chat Button
                Button(action: {
                    showingAIChat = true
                }) {
                    HStack {
                        Image(systemName: "message.fill")
                            .font(.title2)
                        Text("Describe Your Situation")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color.purple, Color.blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(15)
                }
                .padding(.horizontal, 20)
                
                Spacer()
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
    }
}

// Emergency Option Button Component
struct EmergencyOptionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(color)
                    .cornerRadius(20)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// Scale animation on press
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// Panic Button Component
struct PanicButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text("PANIC")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(width: 120, height: 120)
            .background(
                LinearGradient(
                    colors: [.red, .red.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(20)
            .shadow(color: .red.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

struct EmergencyView_Previews: PreviewProvider {
    static var previews: some View {
        EmergencyView()
    }
} 