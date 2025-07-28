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
        default:
            EmptyView()
        }
    }
}

// Breathing Animation Component
struct BreathingAnimationView: View {
    @State private var scale: CGFloat = 0.5
    @State private var isInhaling = true
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.2)],
                            center: .center,
                            startRadius: 50,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(scale)
                    .animation(.easeInOut(duration: 4), value: scale)
                
                Text(isInhaling ? "Breathe In" : "Breathe Out")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .onAppear {
                startBreathing()
            }
            
            Text("Follow the circle")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private func startBreathing() {
        Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { _ in
            isInhaling.toggle()
            scale = isInhaling ? 1.0 : 0.5
            
            // Haptic on breath change
            HapticService.shared.impact(.light)
        }
        .fire()
    }
}

// Grounding Checklist Component
struct GroundingChecklistView: View {
    @State private var checkedItems: Set<String> = []
    
    let items = [
        "5 things you can see",
        "4 things you can touch", 
        "3 things you can hear",
        "2 things you can smell",
        "1 thing you can taste"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            ForEach(items, id: \.self) { item in
                HStack {
                    Image(systemName: checkedItems.contains(item) ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(checkedItems.contains(item) ? .green : .gray)
                        .font(.title2)
                    
                    Text(item)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if checkedItems.contains(item) {
                        checkedItems.remove(item)
                    } else {
                        checkedItems.insert(item)
                        HapticService.shared.impact(.light)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

// Emergency Contacts Quick View
struct EmergencyContactsQuickView: View {
    var body: some View {
        VStack(spacing: 15) {
            // Crisis Line
            Button(action: {
                if let url = URL(string: "tel://988") {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.white)
                    Text("Crisis Lifeline: 988")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .cornerRadius(10)
            }
            
            Text("24/7 confidential support")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        FlowActionView(action: FlowActionData(type: "breathing_animation", data: [:]))
        FlowActionView(action: FlowActionData(type: "grounding_checklist", data: [:]))
        FlowActionView(action: FlowActionData(type: "show_contacts", data: [:]))
    }
    .padding()
} 