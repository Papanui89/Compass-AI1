import SwiftUI
import UIKit

struct FlowPlayerView: View {
    let crisisType: CrisisType
    @Environment(\.dismiss) var dismiss
    @StateObject private var flowEngine = FlowEngine()
    @State private var currentStep = 0
    @State private var isFlowActive = false
    @State private var progress: Double = 0.0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if isFlowActive {
                    // Active Flow View
                    ActiveFlowView(
                        crisisType: crisisType,
                        currentStep: $currentStep,
                        progress: $progress,
                        onComplete: {
                            isFlowActive = false
                            HapticService.shared.notification(.success)
                        }
                    )
                } else {
                    // Flow Selection View
                    FlowSelectionView(
                        crisisType: crisisType,
                        onStartFlow: {
                            isFlowActive = true
                            currentStep = 0
                            progress = 0.0
                            HapticService.shared.impact(.medium)
                        }
                    )
                }
            }
            .navigationTitle("What to Do")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}

// Flow Selection View
struct FlowSelectionView: View {
    let crisisType: CrisisType
    let onStartFlow: () -> Void
    
    var body: some View {
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
            
            // Step-by-step guidance preview
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(Array(crisisType.steps.enumerated()), id: \.offset) { index, step in
                        StepCard(step: step, stepNumber: index + 1)
                    }
                }
                .padding()
            }
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 15) {
                Button("Start Guided Flow") {
                    onStartFlow()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(crisisType.color)
                .foregroundColor(.white)
                .cornerRadius(15)
                .font(.title3)
                .fontWeight(.bold)
                
                Button("I need immediate help") {
                    AppState.shared.activateEmergencyMode(for: crisisType)
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
    }
}

// Active Flow View
struct ActiveFlowView: View {
    let crisisType: CrisisType
    @Binding var currentStep: Int
    @Binding var progress: Double
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Progress header
            VStack(spacing: 10) {
                ProgressBar(progress: progress)
                    .padding(.horizontal)
                
                Text("Step \(currentStep + 1) of \(crisisType.steps.count)")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            // Current step content
            ScrollView {
                VStack(spacing: 20) {
                    // Step card
                    StepCard(step: crisisType.steps[currentStep], stepNumber: currentStep + 1)
                    
                    // Interactive action if available
                    if currentStep < crisisType.steps.count {
                        FlowActionView(action: FlowActionData(type: "grounding_checklist"))
                    }
                }
                .padding()
            }
            
            Spacer()
            
            // Navigation buttons
            HStack(spacing: 20) {
                Button("Previous") {
                    if currentStep > 0 {
                        currentStep -= 1
                        updateProgress()
                        HapticService.shared.impact(.light)
                    }
                }
                .disabled(currentStep == 0)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.3))
                .foregroundColor(.primary)
                .cornerRadius(15)
                
                Button(currentStep == crisisType.steps.count - 1 ? "Complete" : "Next") {
                    if currentStep < crisisType.steps.count - 1 {
                        currentStep += 1
                        updateProgress()
                        HapticService.shared.impact(.light)
                    } else {
                        onComplete()
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(crisisType.color)
                .foregroundColor(.white)
                .cornerRadius(15)
                .font(.title3)
                .fontWeight(.bold)
            }
            .padding()
        }
        .onAppear {
            updateProgress()
        }
    }
    
    private func updateProgress() {
        progress = Double(currentStep + 1) / Double(crisisType.steps.count)
    }
}

struct StepCard: View {
    let step: String
    let stepNumber: Int
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Circle()
                .fill(Color.blue)
                .frame(width: 30, height: 30)
                .overlay(
                    Text("\(stepNumber)")
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