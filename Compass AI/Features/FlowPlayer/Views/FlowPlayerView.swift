import SwiftUI

struct FlowPlayerView: View {
    let crisisType: CrisisType
    @Environment(\.dismiss) var dismiss
    @StateObject private var flowEngine = FlowEngine()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Crisis type header
                VStack(spacing: 10) {
                    Image(systemName: crisisType.icon)
                        .font(.system(size: 60))
                        .foregroundColor(crisisType.color)
                    
                    Text(crisisType.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(crisisType.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                
                // Step-by-step guidance
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(crisisType.steps, id: \.self) { step in
                            StepCard(step: step)
                        }
                    }
                    .padding()
                }
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 15) {
                    Button("Start Guided Flow") {
                        flowEngine.startFlow(for: crisisType)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(crisisType.color)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .font(.title3)
                    .fontWeight(.bold)
                    
                    Button("I need immediate help") {
                        // Trigger emergency mode
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .font(.title3)
                    .fontWeight(.bold)
                }
                .padding()
            }
            .navigationTitle("What to Do")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}

struct StepCard: View {
    let step: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Circle()
                .fill(Color.blue)
                .frame(width: 30, height: 30)
                .overlay(
                    Text("1")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            Text(step)
                .font(.body)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

#Preview {
    FlowPlayerView(crisisType: .panicAttack)
} 