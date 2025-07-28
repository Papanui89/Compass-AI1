import SwiftUI

struct PanicModeView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = EmergencyViewModel()
    
    var body: some View {
        ZStack {
            Color.red.opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Text("EMERGENCY MODE")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                
                Text("Help is on the way")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.9))
                
                // Emergency actions
                VStack(spacing: 20) {
                    Button("Call 911") {
                        viewModel.callEmergencyServices()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .foregroundColor(.red)
                    .cornerRadius(15)
                    .font(.title3)
                    .fontWeight(.bold)
                    
                    Button("Call Emergency Contact") {
                        // Call primary emergency contact
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.9))
                    .foregroundColor(.red)
                    .cornerRadius(15)
                    .font(.title3)
                    .fontWeight(.bold)
                    
                    Button("Send Location to Help") {
                        viewModel.shareLocationWithEmergencyServices()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.8))
                    .foregroundColor(.red)
                    .cornerRadius(15)
                    .font(.title3)
                    .fontWeight(.bold)
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                Button("Exit Emergency Mode") {
                    dismiss()
                }
                .padding()
                .background(Color.white)
                .foregroundColor(.red)
                .cornerRadius(15)
                .font(.headline)
                .fontWeight(.semibold)
            }
            .padding()
        }
        .onAppear {
            // Provide strong haptic feedback
            HapticService.shared.impact(style: .heavy)
            
            // Play emergency sound
            AudioService.shared.playEmergencySound()
        }
    }
}

#Preview {
    PanicModeView()
} 