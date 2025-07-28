import SwiftUI
import AVFoundation

struct RightsView: View {
    @StateObject private var viewModel = LegalViewModel()
    @State private var selectedScenario: LegalScenario?
    @State private var isReadingAloud = false
    @State private var showingLocationPicker = false
    @State private var currentLocation = "California" // Default
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Location Indicator
                HStack {
                    Button(action: { showingLocationPicker = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "location.fill")
                                .font(.caption)
                            Text(currentLocation)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Scenario Cards - Horizontal Scroll
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(viewModel.scenarios) { scenario in
                            ScenarioCard(
                                scenario: scenario,
                                isSelected: selectedScenario?.id == scenario.id
                            ) {
                                selectedScenario = scenario
                                if isReadingAloud {
                                    viewModel.stopReading()
                                    isReadingAloud = false
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 15)
                }
                
                // Main Content
                if let scenario = selectedScenario ?? viewModel.scenarios.first {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Main Script Card
                            MainScriptCard(
                                script: scenario.scripts.joined(separator: "\n\n"),
                                isReadingAloud: $isReadingAloud,
                                onReadAloud: {
                                    isReadingAloud.toggle()
                                    if isReadingAloud {
                                        viewModel.readAloud(scenario.scripts.joined(separator: ". "))
                                    } else {
                                        viewModel.stopReading()
                                    }
                                }
                            )
                            
                            // Quick Tips
                            QuickTipsCard(tips: scenario.quickTips)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Your Rights")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        viewModel.stopReading()
                        selectedScenario = nil
                    }
                }
            }
        }
        .onAppear {
            selectedScenario = viewModel.scenarios.first
            viewModel.loadStateSpecificRights()
        }
        .onDisappear {
            viewModel.stopReading()
        }
        .sheet(isPresented: $showingLocationPicker) {
            LocationPickerView(selectedLocation: $currentLocation)
        }
    }
}

// MARK: - Scenario Card Component
struct ScenarioCard: View {
    let scenario: LegalScenario
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Icon
                Image(systemName: scenario.icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(isSelected ? .white : .blue)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(isSelected ? Color.blue : Color.blue.opacity(0.1))
                    )
                
                // Title
                Text(scenario.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
                
                // Tap indicator
                Text("Tap to view")
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
            }
            .frame(width: 120, height: 120)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.blue : Color(.systemBackground))
                    .shadow(color: isSelected ? .blue.opacity(0.3) : .black.opacity(0.1), radius: isSelected ? 8 : 4, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Main Script Card Component
struct MainScriptCard: View {
    let script: String
    @Binding var isReadingAloud: Bool
    let onReadAloud: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Script Text
            Text(script)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .lineSpacing(4)
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6))
                )
            
            // Action Buttons
            HStack(spacing: 15) {
                // Copy Button
                Button(action: {
                    UIPasteboard.general.string = script
                    HapticService.shared.impact(.light)
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 16, weight: .medium))
                        Text("Copy")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue, lineWidth: 1.5)
                    )
                }
                
                // Speak Aloud Button
                Button(action: onReadAloud) {
                    HStack(spacing: 8) {
                        Image(systemName: isReadingAloud ? "speaker.slash.fill" : "speaker.wave.2.fill")
                            .font(.system(size: 16, weight: .medium))
                        Text(isReadingAloud ? "Stop" : "Speak")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(isReadingAloud ? .red : .white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isReadingAloud ? Color.red : Color.blue)
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Quick Tips Card Component
struct QuickTipsCard: View {
    let tips: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Tips")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            ForEach(tips.prefix(3), id: \.self) { tip in
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.blue)
                    
                    Text(tip)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Location Picker View
struct LocationPickerView: View {
    @Binding var selectedLocation: String
    @Environment(\.dismiss) var dismiss
    
    let states = [
        "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut",
        "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa",
        "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan",
        "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire",
        "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio",
        "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota",
        "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia",
        "Wisconsin", "Wyoming"
    ]
    
    var body: some View {
        NavigationView {
            List(states, id: \.self) { state in
                Button(action: {
                    selectedLocation = state
                    dismiss()
                }) {
                    HStack {
                        Text(state)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if selectedLocation == state {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Select State")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    RightsView()
} 
} 