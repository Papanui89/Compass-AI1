import SwiftUI

struct InteractiveTechniqueView: View {
    let node: ConversationalNode
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Technique header
            VStack(spacing: 8) {
                Text("Interactive Exercise")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.blue)
                
                Text(node.content)
                    .font(.system(size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
            
            // Technique-specific view
            if let technique = node.technique {
                switch technique {
                case "grounding":
                    GroundingTechniqueView(onComplete: onComplete)
                case "box_breathing":
                    BoxBreathingView(onComplete: onComplete)
                case "ice_diving":
                    IceDivingView(onComplete: onComplete)
                case "tipp":
                    TIPPTechniqueView(onComplete: onComplete)
                case "cognitive":
                    CognitiveRestructuringView(onComplete: onComplete)
                case "anchoring":
                    AnchoringPhrasesView(onComplete: onComplete)
                default:
                    // Fallback for unknown techniques
                    VStack(spacing: 16) {
                        Text("Technique: \(technique)")
                            .font(.system(size: 16, weight: .medium))
                        
                        if let timer = node.timer {
                            TimerView(seconds: timer) {
                                onComplete()
                            }
                        } else {
                            Button("Complete") {
                                onComplete()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
            } else {
                // No specific technique, show timer if available
                if let timer = node.timer {
                    TimerView(seconds: timer) {
                        onComplete()
                    }
                } else {
                    Button("Continue") {
                        onComplete()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 8, y: 4)
    }
}

// MARK: - Timer View for techniques with time limits
struct TimerView: View {
    let seconds: Int
    let onComplete: () -> Void
    
    @State private var timeRemaining: Int
    @State private var isActive = false
    
    init(seconds: Int, onComplete: @escaping () -> Void) {
        self.seconds = seconds
        self.onComplete = onComplete
        self._timeRemaining = State(initialValue: seconds)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("\(timeRemaining)s")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.blue)
            
            ProgressView(value: Double(seconds - timeRemaining), total: Double(seconds))
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
            
            HStack(spacing: 20) {
                Button(isActive ? "Pause" : "Start") {
                    isActive.toggle()
                    if isActive {
                        startTimer()
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Button("Complete Early") {
                    onComplete()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
        .onAppear {
            startTimer()
        }
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if timeRemaining > 0 && isActive {
                timeRemaining -= 1
            } else if timeRemaining == 0 {
                timer.invalidate()
                onComplete()
            }
        }
    }
}

// MARK: - Therapist Tip View
struct TherapistTipView: View {
    let tip: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Therapist Tip")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            
            Text(tip)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .italic()
        }
        .padding()
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(8)
    }
} 