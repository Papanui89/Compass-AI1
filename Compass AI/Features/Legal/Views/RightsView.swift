import SwiftUI
import AVFoundation

struct RightsView: View {
    @StateObject private var viewModel = LegalViewModel()
    @State private var selectedScenario: LegalScenario?
    @State private var isReadingAloud = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Scenario Picker
                Picker("Scenario", selection: $selectedScenario) {
                    ForEach(viewModel.scenarios) { scenario in
                        Text(scenario.title).tag(Optional(scenario))
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Scripts and Rights
                if let scenario = selectedScenario ?? viewModel.scenarios.first {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Script
                            VStack(alignment: .leading, spacing: 8) {
                                Text("What to Say")
                                    .font(.headline)
                                ForEach(scenario.scripts, id: \ .self) { script in
                                    Text("\"\(script)\"")
                                        .font(.body)
                                        .padding(.vertical, 4)
                                        .padding(.horizontal, 8)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(10)
                                }
                                Button(action: {
                                    isReadingAloud.toggle()
                                    if isReadingAloud {
                                        viewModel.readAloud(scenario.scripts.joined(separator: ". "))
                                    } else {
                                        viewModel.stopReading()
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: isReadingAloud ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                        Text(isReadingAloud ? "Stop Reading" : "Read Aloud")
                                    }
                                }
                                .padding(.top, 4)
                            }
                            
                            // Know Your Rights
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Know Your Rights")
                                    .font(.headline)
                                ForEach(scenario.rights, id: \ .self) { right in
                                    HStack(alignment: .top) {
                                        Text("•")
                                        Text(right)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("What to Say")
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
        .onDisappear {
            viewModel.stopReading()
        }
        .onAppear {
            selectedScenario = viewModel.scenarios.first
            viewModel.loadStateSpecificRights()
        }
    }
}

// MARK: - Preview
#Preview {
    RightsView()
} 