import SwiftUI

/// Main emergency interface for crisis response - Simple 3-tap design
struct EmergencyView: View {
    @StateObject private var viewModel = EmergencyViewModel()
    @State private var showFlowPlayer = false
    @State private var showRightsView = false
    @State private var showEmergencyContacts = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.red.opacity(0.1), Color.orange.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Panic Button at the top
                    panicButton
                    
                    Spacer()
                    
                    // Main 3-tap interface
                    VStack(spacing: 25) {
                        // What to Do button
                        mainActionButton(
                            title: "What to Do",
                            subtitle: "Step-by-step guidance",
                            icon: "list.bullet.circle.fill",
                            color: .purple
                        ) {
                            showFlowPlayer = true
                        }
                        
                        // What to Say button
                        mainActionButton(
                            title: "What to Say",
                            subtitle: "Know your rights",
                            icon: "text.bubble.fill",
                            color: .blue
                        ) {
                            showRightsView = true
                        }
                        
                        // Who to Call button
                        mainActionButton(
                            title: "Who to Call",
                            subtitle: "Emergency contacts",
                            icon: "phone.circle.fill",
                            color: .orange
                        ) {
                            showEmergencyContacts = true
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding(.top, 20)
            }
            .navigationTitle("Emergency")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarHidden(true)
            .alert("Emergency Alert", isPresented: $viewModel.showEmergencyAlert) {
                Button("Call 911", role: .destructive) {
                    viewModel.callEmergencyServices()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text(viewModel.emergencyAlertMessage)
            }
            .sheet(isPresented: $showFlowPlayer) {
                FlowPlayerView()
            }
            .sheet(isPresented: $showRightsView) {
                RightsView()
            }
            .sheet(isPresented: $showEmergencyContacts) {
                EmergencyContactsView()
            }
        }
        .onAppear {
            viewModel.loadEmergencyData()
        }
    }
    
    // MARK: - View Components
    
    private var panicButton: some View {
        Button(action: {
            viewModel.activatePanicMode()
        }) {
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
    
    private func mainActionButton(
        title: String,
        subtitle: String,
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(.white)
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(
                LinearGradient(
                    colors: [color, color.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(20)
            .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Placeholder Views (to be implemented)

struct FlowPlayerView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("What to Do")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Step-by-step guidance will be implemented here")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("What to Do")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct RightsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("What to Say")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Know your rights information will be implemented here")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("What to Say")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Preview

struct EmergencyView_Previews: PreviewProvider {
    static var previews: some View {
        EmergencyView()
    }
} 