import SwiftUI
import UIKit

struct FlowPlayerView: View {
    let crisisType: CrisisType
    @Environment(\.dismiss) var dismiss
    @StateObject private var flowEngine = FlowEngine()
    @State private var currentStep = 0
    @State private var isFlowActive = false
    @State private var progress: Double = 0.0
    @State private var showSkipAlert = false
    @State private var showExitAlert = false
    @State private var timeEstimate = "2 minutes to calm"
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [crisisType.color.opacity(0.1), Color(.systemBackground)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if isFlowActive {
                        // Active Flow View
                        ActiveFlowView(
                            crisisType: crisisType,
                            currentStep: $currentStep,
                            progress: $progress,
                            timeEstimate: $timeEstimate,
                            showSkipAlert: $showSkipAlert,
                            showExitAlert: $showExitAlert,
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
            }
            .navigationTitle("What to Do")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Exit") {
                    showExitAlert = true
                }
                .foregroundColor(.red),
                trailing: Button("Done") {
                    dismiss()
                }
            )
        }
        .alert("Skip this step?", isPresented: $showSkipAlert) {
            Button("Skip") {
                if currentStep < crisisType.steps.count - 1 {
                    currentStep += 1
                    progress = Double(currentStep + 1) / Double(crisisType.steps.count)
                    HapticService.shared.impact(.light)
                }
            }
            Button("Continue", role: .cancel) { }
        } message: {
            Text("This step might be helpful, but you can skip if needed.")
        }
        .alert("Exit Crisis Guide?", isPresented: $showExitAlert) {
            Button("Exit", role: .destructive) {
                dismiss()
            }
            Button("Continue", role: .cancel) { }
        } message: {
            Text("Are you sure you want to exit? Help is still available.")
        }
    }
}

// MARK: - Flow Selection View
struct FlowSelectionView: View {
    let crisisType: CrisisType
    let onStartFlow: () -> Void
    
    var body: some View {
        VStack(spacing: 25) {
            // Crisis type header with animation
            VStack(spacing: 15) {
                ZStack {
                    Circle()
                        .fill(crisisType.color.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: crisisType.icon)
                        .font(.system(size: 50))
                        .foregroundColor(crisisType.color)
                }
                .scaleEffect(1.0)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: UUID())
                
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
            
            // Step preview with icons
            VStack(spacing: 15) {
                Text("What we'll do together:")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                ForEach(Array(crisisType.steps.enumerated()), id: \.offset) { index, step in
                    StepPreviewCard(step: step, stepNumber: index + 1, crisisType: crisisType)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 15) {
                Button(action: onStartFlow) {
                    HStack(spacing: 10) {
                        Image(systemName: "play.fill")
                            .font(.title2)
                        Text("Start Guided Flow")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [crisisType.color, crisisType.color.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
                    .shadow(color: crisisType.color.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                
                Button("I need immediate help") {
                    AppState.shared.activateEmergencyMode(for: crisisType)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color.red, Color.red.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(20)
                .font(.title3)
                .fontWeight(.bold)
            }
            .padding()
        }
    }
}

// MARK: - Active Flow View
struct ActiveFlowView: View {
    let crisisType: CrisisType
    @Binding var currentStep: Int
    @Binding var progress: Double
    @Binding var timeEstimate: String
    @Binding var showSkipAlert: Bool
    @Binding var showExitAlert: Bool
    let onComplete: () -> Void
    
    @State private var showContinueButton = false
    @State private var stepStartTime = Date()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with step indicators
            VStack(spacing: 15) {
                // Step indicators
                StepIndicatorsView(
                    totalSteps: crisisType.steps.count,
                    currentStep: currentStep,
                    progress: progress
                )
                
                // Time estimate
                Text(timeEstimate)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
            .padding()
            
            // Main content area
            ScrollView {
                VStack(spacing: 25) {
                    // Step content with visual elements
                    StepContentView(
                        step: crisisType.steps[currentStep],
                        stepNumber: currentStep + 1,
                        crisisType: crisisType,
                        showContinueButton: $showContinueButton
                    )
                    
                    // Interactive action if available
                    if currentStep < crisisType.steps.count {
                        FlowActionView(action: FlowActionData(type: getActionTypeForStep(currentStep)))
                    }
                }
                .padding()
            }
            
            Spacer()
            
            // Navigation buttons
            HStack(spacing: 15) {
                // Previous button
                Button("Previous") {
                    if currentStep > 0 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep -= 1
                            updateProgress()
                        }
                        HapticService.shared.impact(.light)
                    }
                }
                .disabled(currentStep == 0)
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .background(Color(.systemGray5))
                .foregroundColor(.primary)
                .cornerRadius(15)
                .font(.body)
                .fontWeight(.medium)
                
                // Skip button
                Button("Skip") {
                    showSkipAlert = true
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .background(Color.orange.opacity(0.1))
                .foregroundColor(.orange)
                .cornerRadius(15)
                .font(.body)
                .fontWeight(.medium)
                
                // Continue/Complete button
                Button(currentStep == crisisType.steps.count - 1 ? "Complete" : "Continue") {
                    if currentStep < crisisType.steps.count - 1 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep += 1
                            updateProgress()
                        }
                        HapticService.shared.impact(.light)
                    } else {
                        onComplete()
                    }
                }
                .opacity(showContinueButton ? 1.0 : 0.6)
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .background(
                    LinearGradient(
                        colors: [crisisType.color, crisisType.color.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(15)
                .font(.body)
                .fontWeight(.semibold)
            }
            .padding()
        }
        .onAppear {
            updateProgress()
            stepStartTime = Date()
            showContinueButton = false
            
            // Show continue button after 30 seconds for guided steps
            DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showContinueButton = true
                }
            }
        }
        .onChange(of: currentStep) { _ in
            stepStartTime = Date()
            showContinueButton = false
            
            // Show continue button after 30 seconds for guided steps
            DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showContinueButton = true
                }
            }
        }
    }
    
    private func updateProgress() {
        withAnimation(.easeInOut(duration: 0.3)) {
            progress = Double(currentStep + 1) / Double(crisisType.steps.count)
        }
    }
    
    private func getActionTypeForStep(_ step: Int) -> String {
        // Map steps to action types based on content
        let stepContent = crisisType.steps[step].lowercased()
        
        if stepContent.contains("breath") || stepContent.contains("inhale") || stepContent.contains("exhale") {
            return "breathing_animation"
        } else if stepContent.contains("see") || stepContent.contains("touch") || stepContent.contains("hear") {
            return "grounding_checklist"
        } else if stepContent.contains("call") || stepContent.contains("988") || stepContent.contains("911") {
            return "show_contacts"
        } else {
            return "statement"
        }
    }
}

// MARK: - Step Indicators View
struct StepIndicatorsView: View {
    let totalSteps: Int
    let currentStep: Int
    let progress: Double
    
    var body: some View {
        VStack(spacing: 10) {
            // Step text
            Text("Step \(currentStep + 1) of \(totalSteps)")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            // Step dots
            HStack(spacing: 8) {
                ForEach(0..<totalSteps, id: \.self) { index in
                    Circle()
                        .fill(index <= currentStep ? Color.blue : Color(.systemGray4))
                        .frame(width: index == currentStep ? 12 : 8, height: index == currentStep ? 12 : 8)
                        .scaleEffect(index == currentStep ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: currentStep)
                }
            }
        }
    }
}

// MARK: - Step Content View
struct StepContentView: View {
    let step: String
    let stepNumber: Int
    let crisisType: CrisisType
    @Binding var showContinueButton: Bool
    
    @State private var iconScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 20) {
            // Icon with animation
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [crisisType.color.opacity(0.2), crisisType.color.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: getIconForStep(step))
                    .font(.system(size: 35))
                    .foregroundColor(crisisType.color)
                    .scaleEffect(iconScale)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    iconScale = 1.1
                }
            }
            
            // Step text with encouraging message
            VStack(spacing: 15) {
                Text(getEncouragingMessage(step))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text(step)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal)
    }
    
    private func getIconForStep(_ step: String) -> String {
        let stepLower = step.lowercased()
        
        if stepLower.contains("breath") || stepLower.contains("inhale") || stepLower.contains("exhale") {
            return "🫁"
        } else if stepLower.contains("see") || stepLower.contains("touch") || stepLower.contains("hear") {
            return "👁️"
        } else if stepLower.contains("call") || stepLower.contains("988") || stepLower.contains("911") {
            return "📞"
        } else if stepLower.contains("comfort") || stepLower.contains("position") {
            return "❤️"
        } else if stepLower.contains("remind") || stepLower.contains("pass") {
            return "💭"
        } else {
            return "✨"
        }
    }
    
    private func getEncouragingMessage(_ step: String) -> String {
        let stepLower = step.lowercased()
        
        if stepLower.contains("breath") || stepLower.contains("inhale") || stepLower.contains("exhale") {
            return "Let's slow down your breathing"
        } else if stepLower.contains("see") || stepLower.contains("touch") || stepLower.contains("hear") {
            return "Let's ground yourself"
        } else if stepLower.contains("call") || stepLower.contains("988") || stepLower.contains("911") {
            return "You're not alone - help is here"
        } else if stepLower.contains("comfort") || stepLower.contains("position") {
            return "Get comfortable"
        } else if stepLower.contains("remind") || stepLower.contains("pass") {
            return "Remember: This will pass"
        } else {
            return "You're doing great"
        }
    }
}

// MARK: - Step Preview Card
struct StepPreviewCard: View {
    let step: String
    let stepNumber: Int
    let crisisType: CrisisType
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Step number with icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [crisisType.color, crisisType.color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                Text("\(stepNumber)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Text(step)
                .font(.body)
                .multilineTextAlignment(.leading)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(crisisType.color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

#Preview {
    FlowPlayerView(crisisType: .panicAttack)
} 