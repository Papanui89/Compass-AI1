import SwiftUI
import Foundation

/// ViewModel for managing emergency interface state and logic
class EmergencyViewModel: ObservableObject {
    @Published var crisisTypes: [CrisisType] = []
    @Published var emergencyContacts: [EmergencyContact] = []
    @Published var recentCrises: [Crisis] = []
    @Published var isLoading = false
    @Published var showSettings = false
    @Published var showAddContact = false
    @Published var showEmergencyAlert = false
    @Published var emergencyAlertMessage = ""
    @Published var selectedCrisisType: CrisisType?
    @Published var isPanicModeActive = false
    @Published var isStealthModeActive = false
    
    private let secureStorage = SecureStorage.shared
    private let hapticService = HapticService.shared
    private let audioService = AudioService.shared
    private let locationService = LocationService.shared
    
    init() {
        setupCrisisTypes()
    }
    
    // MARK: - Public Methods
    
    /// Loads emergency data from storage
    func loadEmergencyData() {
        isLoading = true
        
        Task {
            await loadEmergencyContacts()
            await loadRecentCrises()
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    /// Selects a crisis type and initiates appropriate response
    func selectCrisisType(_ crisisType: CrisisType) {
        selectedCrisisType = crisisType
        
        // Provide haptic feedback
        hapticService.impact(.medium)
        
        // Navigate to crisis flow
        navigateToCrisisFlow(for: crisisType)
    }
    
    /// Activates panic mode for immediate emergency response
    func activatePanicMode() {
        isPanicModeActive = true
        
        // Provide strong haptic feedback
        hapticService.impact(.heavy)
        
        // Play emergency sound
        audioService.playEmergencySound()
        
        // Show emergency alert
        emergencyAlertMessage = "Panic mode activated. Do you need immediate emergency assistance?"
        showEmergencyAlert = true
        
        // Log panic activation
        logPanicActivation()
    }
    
    /// Activates stealth mode for discreet emergency access
    func activateStealthMode() {
        isStealthModeActive = true
        
        // Provide subtle haptic feedback
        hapticService.impact(.light)
        
        // Navigate to stealth interface
        navigateToStealthMode()
    }
    
    /// Performs quick exit to hide the app
    func quickExit() {
        // Provide haptic feedback
        hapticService.impact(.medium)
        
        // Hide app (this would be implemented at the app level)
        performQuickExit()
    }
    
    /// Calls an emergency contact
    func callContact(_ contact: EmergencyContact) {
        // Provide haptic feedback
        hapticService.impact(.medium)
        
        // Make the call
        makePhoneCall(to: contact.phoneNumber)
        
        // Log the call
        logEmergencyCall(to: contact)
    }
    
    /// Calls emergency services (911)
    func callEmergencyServices() {
        // Provide strong haptic feedback
        hapticService.impact(.heavy)
        
        // Make emergency call
        makePhoneCall(to: "911")
        
        // Log emergency call
        logEmergencyServicesCall()
        
        // Reset panic mode
        isPanicModeActive = false
    }
    
    /// Views crisis details
    func viewCrisisDetails(_ crisis: Crisis) {
        // Navigate to crisis details view
        navigateToCrisisDetails(crisis)
    }
    
    // MARK: - Private Methods
    
    private func setupCrisisTypes() {
        crisisTypes = CrisisType.allCases
    }
    
    private func loadEmergencyContacts() async {
        do {
            let contacts = try secureStorage.retrieveEmergencyContacts()
            DispatchQueue.main.async {
                self.emergencyContacts = contacts
            }
        } catch {
            print("Failed to load emergency contacts: \(error)")
        }
    }
    
    private func loadRecentCrises() async {
        // Load recent crises from storage
        // This would typically come from a database or cache
        let recentCrises = await getRecentCrises()
        
        DispatchQueue.main.async {
            self.recentCrises = recentCrises
        }
    }
    
    private func navigateToCrisisFlow(for crisisType: CrisisType) {
        // Navigate to appropriate crisis flow
        // This would be handled by the navigation system
        print("Navigating to crisis flow for: \(crisisType.displayName)")
    }
    
    private func navigateToStealthMode() {
        // Navigate to stealth mode interface
        print("Navigating to stealth mode")
    }
    
    private func navigateToCrisisDetails(_ crisis: Crisis) {
        // Navigate to crisis details view
        print("Navigating to crisis details for: \(crisis.id)")
    }
    
    private func performQuickExit() {
        // Hide the app or switch to a different app
        // This would be implemented at the app level
        print("Performing quick exit")
    }
    
    private func makePhoneCall(to phoneNumber: String) {
        // Make phone call using URL scheme
        if let url = URL(string: "tel:\(phoneNumber)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func logPanicActivation() {
        // Log panic mode activation for analytics
        let event = UserInteraction(
            type: .emergencyAction,
            screen: "EmergencyView",
            action: "panic_activation",
            data: ["timestamp": Date().timeIntervalSince1970.description]
        )
        
        logInteraction(event)
    }
    
    private func logEmergencyCall(to contact: EmergencyContact) {
        // Log emergency call for analytics
        let event = UserInteraction(
            type: .emergencyAction,
            screen: "EmergencyView",
            action: "emergency_call",
            data: [
                "contact_id": contact.id,
                "contact_name": contact.name,
                "timestamp": Date().timeIntervalSince1970.description
            ]
        )
        
        logInteraction(event)
    }
    
    private func logEmergencyServicesCall() {
        // Log emergency services call for analytics
        let event = UserInteraction(
            type: .emergencyAction,
            screen: "EmergencyView",
            action: "emergency_services_call",
            data: ["timestamp": Date().timeIntervalSince1970.description]
        )
        
        logInteraction(event)
    }
    
    private func logInteraction(_ interaction: UserInteraction) {
        // Log user interaction for analytics
        // This would typically be sent to an analytics service
        print("Logging interaction: \(interaction.type.rawValue)")
    }
    
    private func getRecentCrises() async -> [Crisis] {
        // Get recent crises from storage
        // This is a placeholder implementation
        return []
    }
}

// MARK: - Emergency Settings View

struct EmergencySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var enableHapticFeedback = true
    @State private var enableEmergencySounds = true
    @State private var enableLocationSharing = false
    @State private var enableAutoDial = false
    @State private var panicButtonEnabled = true
    @State private var stealthModeEnabled = true
    
    var body: some View {
        NavigationView {
            Form {
                Section("Emergency Response") {
                    Toggle("Haptic Feedback", isOn: $enableHapticFeedback)
                    Toggle("Emergency Sounds", isOn: $enableEmergencySounds)
                    Toggle("Location Sharing", isOn: $enableLocationSharing)
                    Toggle("Auto-dial Emergency", isOn: $enableAutoDial)
                }
                
                Section("Quick Actions") {
                    Toggle("Panic Button", isOn: $panicButtonEnabled)
                    Toggle("Stealth Mode", isOn: $stealthModeEnabled)
                }
                
                Section("Emergency Contacts") {
                    NavigationLink("Manage Contacts") {
                        EmergencyContactsView()
                    }
                    
                    NavigationLink("Add New Contact") {
                        AddEmergencyContactView()
                    }
                }
                
                Section("Privacy & Security") {
                    NavigationLink("Privacy Settings") {
                        PrivacySettingsView()
                    }
                    
                    NavigationLink("Data Management") {
                        DataManagementView()
                    }
                }
            }
            .navigationTitle("Emergency Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Placeholder Views

struct EmergencyContactsView: View {
    var body: some View {
        Text("Emergency Contacts")
            .navigationTitle("Emergency Contacts")
    }
}

struct AddEmergencyContactView: View {
    var body: some View {
        Text("Add Emergency Contact")
            .navigationTitle("Add Contact")
    }
}

struct PrivacySettingsView: View {
    var body: some View {
        Text("Privacy Settings")
            .navigationTitle("Privacy Settings")
    }
}

struct DataManagementView: View {
    var body: some View {
        Text("Data Management")
            .navigationTitle("Data Management")
    }
} 