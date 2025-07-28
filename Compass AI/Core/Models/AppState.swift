import Foundation
import SwiftUI

/// Global app state management
class AppState: ObservableObject {
    @Published var isEmergencyMode = false
    @Published var currentCrisisType: CrisisType?
    @Published var isStealthMode = false
    @Published var lastEmergencyAction: Date?
    
    static let shared = AppState()
    
    private init() {}
    
    func activateEmergencyMode(for crisisType: CrisisType? = nil) {
        isEmergencyMode = true
        currentCrisisType = crisisType
        lastEmergencyAction = Date()
        
        // Provide haptic feedback
        HapticService.shared.impact(.heavy)
        
        // Play emergency sound
        AudioService.shared.playEmergencySound()
    }
    
    func deactivateEmergencyMode() {
        isEmergencyMode = false
        currentCrisisType = nil
    }
    
    func toggleStealthMode() {
        isStealthMode.toggle()
        HapticService.shared.impact(style: .medium)
    }
} 