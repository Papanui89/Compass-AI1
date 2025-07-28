import SwiftUI
import UIKit

struct FlowActionView: View {
    let action: FlowActionData
    @State private var isAnimating = false
    
    var body: some View {
        switch action.type {
        case "breathing_animation":
            BreathingAnimationView()
        case "grounding_checklist":
            GroundingChecklistView()
        case "show_contacts":
            EmergencyContactsQuickView()
        case "timer":
            TimerView()
        case "statement":
            StatementView()
        default:
            EmptyView()
        }
    }
}

// MARK: - Enhanced Breathing Animation Component
struct BreathingAnimationView: View {
    @State private var scale: CGFloat = 0.5
    @State private var isInhaling = true
    @State private var breathCount = 0
    @State private var showInstructions = true
    
    var body: some View {
        VStack(spacing: 25) {
            // Breathing circle with enhanced animation
            ZStack {
                // Outer pulse ring
                Circle()
                    .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                    .frame(width: 220, height: 220)
                    .scaleEffect(isInhaling ? 1.2 : 0.8)
                    .opacity(isInhaling ? 0.8 : 0.3)
                    .animation(.easeInOut(duration: 4), value: isInhaling)
                
                // Main breathing circle
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.blue.opacity(0.4), Color.purple.opacity(0.2)],
                            center: .center,
                            startRadius: 50,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(scale)
                    .animation(.easeInOut(duration: 4), value: scale)
                
                // Breath count
                VStack(spacing: 8) {
                    Text(isInhaling ? "Breathe In" : "Breathe Out")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("\(breathCount)")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
            .onAppear {
                startBreathing()
            }
            
            // Instructions
            if showInstructions {
                VStack(spacing: 10) {
                    Text("Follow the circle")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text("Inhale as it grows, exhale as it shrinks")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.blue.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                )
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showInstructions = false
                        }
                    }
                }
            }
        }
    }
    
    private func startBreathing() {
        Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { _ in
            isInhaling.toggle()
            scale = isInhaling ? 1.0 : 0.5
            
            if isInhaling {
                breathCount += 1
            }
            
            // Haptic feedback
            HapticService.shared.impact(.light)
        }
        .fire()
    }
}

// MARK: - Enhanced Grounding Checklist Component
struct GroundingChecklistView: View {
    @State private var checkedItems: Set<String> = []
    @State private var showCelebration = false
    
    let items = [
        ("5 things you can see", "👁️"),
        ("4 things you can touch", "✋"),
        ("3 things you can hear", "👂"),
        ("2 things you can smell", "👃"),
        ("1 thing you can taste", "👅")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Text("Grounding Exercise")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if checkedItems.count == items.count {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                        .scaleEffect(showCelebration ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.3).repeatCount(3), value: showCelebration)
                }
            }
            
            // Checklist items
            VStack(spacing: 12) {
                ForEach(items, id: \.0) { item, icon in
                    HStack(spacing: 15) {
                        // Icon
                        Text(icon)
                            .font(.title2)
                        
                        // Checkbox
                        ZStack {
                            Circle()
                                .fill(checkedItems.contains(item) ? Color.green : Color(.systemGray4))
                                .frame(width: 24, height: 24)
                            
                            if checkedItems.contains(item) {
                                Image(systemName: "checkmark")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                        .scaleEffect(checkedItems.contains(item) ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: checkedItems.contains(item))
                        
                        // Text
                        Text(item)
                            .font(.body)
                            .foregroundColor(checkedItems.contains(item) ? .secondary : .primary)
                            .strikethrough(checkedItems.contains(item))
                        
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if checkedItems.contains(item) {
                            checkedItems.remove(item)
                        } else {
                            checkedItems.insert(item)
                            HapticService.shared.impact(.light)
                            
                            // Check if all items are completed
                            if checkedItems.count == items.count {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    showCelebration = true
                                    HapticService.shared.notification(.success)
                                }
                            }
                        }
                    }
                }
            }
            
            // Progress indicator
            if checkedItems.count > 0 {
                VStack(spacing: 8) {
                    HStack {
                        Text("Progress")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(checkedItems.count)/\(items.count)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    ProgressView(value: Double(checkedItems.count), total: Double(items.count))
                        .progressViewStyle(LinearProgressViewStyle(tint: .green))
                }
                .padding(.top, 10)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Enhanced Emergency Contacts Quick View
struct EmergencyContactsQuickView: View {
    @State private var showConfirmation = false
    @State private var selectedContact: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Image(systemName: "phone.circle.fill")
                    .font(.title)
                    .foregroundColor(.red)
                
                Text("Emergency Contacts")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // Contact buttons
            VStack(spacing: 15) {
                // Crisis Lifeline
                ContactButton(
                    title: "Crisis Lifeline",
                    subtitle: "988 - 24/7 confidential support",
                    icon: "heart.fill",
                    color: .red
                ) {
                    selectedContact = "988"
                    showConfirmation = true
                }
                
                // Emergency Services
                ContactButton(
                    title: "Emergency Services",
                    subtitle: "911 - Immediate help",
                    icon: "exclamationmark.triangle.fill",
                    color: .orange
                ) {
                    selectedContact = "911"
                    showConfirmation = true
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .alert("Call \(selectedContact)?", isPresented: $showConfirmation) {
            Button("Call") {
                if let url = URL(string: "tel://\(selectedContact)") {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will open your phone app to make the call.")
        }
    }
}

// MARK: - Contact Button Component
struct ContactButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(color)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "phone.fill")
                    .font(.title3)
                    .foregroundColor(color)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Timer View Component
struct TimerView: View {
    @State private var timeRemaining = 60 // 1 minute
    @State private var isActive = false
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 20) {
            // Timer display
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.2), lineWidth: 8)
                    .frame(width: 150, height: 150)
                
                Circle()
                    .trim(from: 0, to: 1 - (Double(timeRemaining) / 60.0))
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: timeRemaining)
                
                VStack(spacing: 5) {
                    Text("\(timeRemaining)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("seconds")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Control button
            Button(isActive ? "Pause" : "Start") {
                if isActive {
                    pauseTimer()
                } else {
                    startTimer()
                }
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 12)
            .background(isActive ? Color.orange : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(15)
            .font(.body)
            .fontWeight(.semibold)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    private func startTimer() {
        isActive = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
                HapticService.shared.impact(.light)
            } else {
                pauseTimer()
                HapticService.shared.notification(.success)
            }
        }
    }
    
    private func pauseTimer() {
        isActive = false
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Statement View Component
struct StatementView: View {
    @State private var showEncouragement = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Encouraging message
            VStack(spacing: 15) {
                Image(systemName: "heart.fill")
                    .font(.title)
                    .foregroundColor(.pink)
                    .scaleEffect(showEncouragement ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: showEncouragement)
                
                Text("You're doing great!")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Take a moment to acknowledge your strength")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.pink.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.pink.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .onAppear {
            showEncouragement = true
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        FlowActionView(action: FlowActionData(type: "breathing_animation", data: [:]))
        FlowActionView(action: FlowActionData(type: "grounding_checklist", data: [:]))
        FlowActionView(action: FlowActionData(type: "show_contacts", data: [:]))
        FlowActionView(action: FlowActionData(type: "timer", data: [:]))
        FlowActionView(action: FlowActionData(type: "statement", data: [:]))
    }
    .padding()
} 