import SwiftUI
import Foundation

/// ViewModel for managing emergency interface state and logic
@MainActor
final class EmergencyViewModel: ObservableObject {
    @Published var crisisTypes: [CrisisType] = []
    @Published var emergencyContacts: [EmergencyContact] = []
    @Published var recentCrises: [CrisisType] = []
    @Published var smartSuggestion: SmartSuggestion?
    @Published var isLoading = false
    @Published var showSettings = false
    @Published var showAddContact = false
    @Published var showEmergencyAlert = false
    @Published var emergencyAlertMessage = ""
    @Published var selectedCrisisType: CrisisType?
    @Published var isPanicModeActive = false
    @Published var isStealthModeActive = false
    @Published var appOpenCount = 0
    @Published var lastOpenTime: Date?
    
    private let secureStorage = SecureStorage.shared
    private let hapticService = HapticService.shared
    private let audioService = AudioService.shared
    private let locationService = LocationService.shared
    
    init() {
        setupCrisisTypes()
        loadAppUsageData()
    }
    
    // MARK: - Public Methods
    
    /// Loads emergency data from storage
    func loadEmergencyData() {
        isLoading = true
        
        Task {
            await loadEmergencyContacts()
            loadRecentCrises()
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    /// Loads recent crises for quick access
    func loadRecentCrises() {
        // Load from UserDefaults or secure storage
        if let recentData = UserDefaults.standard.array(forKey: "recentCrises") as? [String] {
            recentCrises = recentData.compactMap { CrisisType(rawValue: $0) }
        }
    }
    
    /// Generates smart suggestions based on time, location, and usage patterns
    func generateSmartSuggestion() {
        let hour = Calendar.current.component(.hour, from: Date())
        let isLateNight = hour >= 22 || hour <= 6
        let isSchoolTime = hour >= 7 && hour <= 15
        
        // Check if user has opened app multiple times recently
        let shouldShowSupport = appOpenCount >= 3 && 
            lastOpenTime?.timeIntervalSinceNow ?? 0 > -3600 // Within last hour
        
        if shouldShowSupport {
            smartSuggestion = SmartSuggestion(
                title: "Hey, rough day?",
                subtitle: "I'm here if you need to talk",
                icon: "heart.fill",
                crisisType: .panicAttack
            )
        } else if isLateNight {
            smartSuggestion = SmartSuggestion(
                title: "Can't sleep?",
                subtitle: "Late night anxiety is common",
                icon: "moon.fill",
                crisisType: .panicAttack
            )
        } else if isSchoolTime {
            smartSuggestion = SmartSuggestion(
                title: "School stress?",
                subtitle: "You're not alone in this",
                icon: "graduationcap.fill",
                crisisType: .bullying
            )
        }
    }
    
    /// Records app usage for smart suggestions
    func recordAppOpen() {
        appOpenCount += 1
        lastOpenTime = Date()
        
        // Save to UserDefaults
        UserDefaults.standard.set(appOpenCount, forKey: "appOpenCount")
        UserDefaults.standard.set(lastOpenTime, forKey: "lastOpenTime")
        
        // Generate new suggestion if needed
        generateSmartSuggestion()
    }
    
    /// Adds a crisis to recent list
    func addToRecentCrises(_ crisisType: CrisisType) {
        // Remove if already exists
        recentCrises.removeAll { $0 == crisisType }
        
        // Add to beginning
        recentCrises.insert(crisisType, at: 0)
        
        // Keep only last 5
        if recentCrises.count > 5 {
            recentCrises = Array(recentCrises.prefix(5))
        }
        
        // Save to UserDefaults
        let recentData = recentCrises.map { $0.rawValue }
        UserDefaults.standard.set(recentData, forKey: "recentCrises")
    }
    
    /// Analyzes text for crisis keywords and suggests appropriate help
    func analyzeTextForCrisis(_ text: String) -> CrisisType? {
        let lowercased = text.lowercased()
        
        // Panic/Anxiety keywords
        if lowercased.contains("panic") || lowercased.contains("anxiety") || 
           lowercased.contains("freaking") || lowercased.contains("overwhelmed") ||
           lowercased.contains("can't breathe") || lowercased.contains("heart racing") {
            return .panicAttack
        }
        
        // Suicide keywords
        if lowercased.contains("die") || lowercased.contains("kill myself") ||
           lowercased.contains("end it") || lowercased.contains("suicide") ||
           lowercased.contains("want to die") || lowercased.contains("no reason to live") {
            return .suicide
        }
        
        // Bullying keywords
        if lowercased.contains("bully") || lowercased.contains("teased") ||
           lowercased.contains("picked on") || lowercased.contains("excluded") ||
           lowercased.contains("hate school") || lowercased.contains("no friends") {
            return .bullying
        }
        
        // Police encounter keywords
        if lowercased.contains("cops") || lowercased.contains("police") ||
           lowercased.contains("arrested") || lowercased.contains("detained") ||
           lowercased.contains("pulled over") || lowercased.contains("questioned") {
            return .harassment
        }
        
        // Medical emergency keywords
        if lowercased.contains("hurt") || lowercased.contains("pain") ||
           lowercased.contains("bleeding") || lowercased.contains("broken") ||
           lowercased.contains("can't move") || lowercased.contains("unconscious") {
            return .medicalEmergency
        }
        
        // Domestic violence keywords
        if lowercased.contains("abuse") || lowercased.contains("hit") ||
           lowercased.contains("scared at home") || lowercased.contains("unsafe") ||
           lowercased.contains("parent") || lowercased.contains("family") {
            return .domesticViolence
        }
        
        return nil
    }
    
    /// Selects a crisis type and initiates appropriate response
    func selectCrisisType(_ crisisType: CrisisType) {
        selectedCrisisType = crisisType
        
        // Add to recent crises
        addToRecentCrises(crisisType)
        
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
    
    private func loadAppUsageData() {
        appOpenCount = UserDefaults.standard.integer(forKey: "appOpenCount")
        lastOpenTime = UserDefaults.standard.object(forKey: "lastOpenTime") as? Date
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

// EmergencyContactsView is now in Features/Emergency/Views/EmergencyContactsView.swift

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
