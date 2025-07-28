import Foundation
import SwiftUI
import UIKit

/// Service for providing haptic feedback throughout the app
class HapticService {
    static let shared = HapticService()
    
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator()
    private let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    private let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
    
    private var isEnabled = true
    
    private init() {
        prepareHapticEngines()
    }
    
    // MARK: - Public Methods
    
    /// Provides impact feedback with specified style
    func impact(_ style: HapticFeedbackStyle) {
        guard isEnabled else { return }
        
        DispatchQueue.main.async {
            self.impactFeedbackGenerator.impactOccurred(intensity: self.intensityForStyle(style))
        }
    }
    
    /// Provides notification feedback with specified type
    func notification(_ type: NotificationFeedbackType) {
        guard isEnabled else { return }
        
        DispatchQueue.main.async {
            self.notificationFeedbackGenerator.notificationOccurred(type.uiKitType)
        }
    }
    
    /// Provides selection feedback
    func selection() {
        guard isEnabled else { return }
        
        DispatchQueue.main.async {
            self.selectionFeedbackGenerator.selectionChanged()
        }
    }
    
    /// Provides emergency haptic feedback
    func emergency() {
        guard isEnabled else { return }
        
        // Strong, repeated haptic feedback for emergency situations
        DispatchQueue.main.async {
            for _ in 0..<3 {
                self.impactFeedbackGenerator.impactOccurred(intensity: 1.0)
                Thread.sleep(forTimeInterval: 0.1)
            }
        }
    }
    
    /// Provides crisis detection feedback
    func crisisDetected() {
        guard isEnabled else { return }
        
        // Medium intensity feedback for crisis detection
        DispatchQueue.main.async {
            self.impactFeedbackGenerator.impactOccurred(intensity: 0.7)
        }
    }
    
    /// Provides flow completion feedback
    func flowCompleted() {
        guard isEnabled else { return }
        
        // Success notification for flow completion
        DispatchQueue.main.async {
            self.notificationFeedbackGenerator.notificationOccurred(.success)
        }
    }
    
    /// Provides flow error feedback
    func flowError() {
        guard isEnabled else { return }
        
        // Error notification for flow errors
        DispatchQueue.main.async {
            self.notificationFeedbackGenerator.notificationOccurred(.error)
        }
    }
    
    /// Provides button press feedback
    func buttonPress() {
        guard isEnabled else { return }
        
        // Light impact for button presses
        DispatchQueue.main.async {
            self.impactFeedbackGenerator.impactOccurred(intensity: 0.3)
        }
    }
    
    /// Provides navigation feedback
    func navigation() {
        guard isEnabled else { return }
        
        // Selection feedback for navigation
        DispatchQueue.main.async {
            self.selectionFeedbackGenerator.selectionChanged()
        }
    }
    
    /// Provides panic button feedback
    func panicButton() {
        guard isEnabled else { return }
        
        // Strong, urgent feedback for panic button
        DispatchQueue.main.async {
            for _ in 0..<5 {
                self.impactFeedbackGenerator.impactOccurred(intensity: 1.0)
                Thread.sleep(forTimeInterval: 0.05)
            }
        }
    }
    
    /// Provides stealth mode feedback
    func stealthMode() {
        guard isEnabled else { return }
        
        // Very light feedback for stealth mode
        DispatchQueue.main.async {
            self.impactFeedbackGenerator.impactOccurred(intensity: 0.1)
        }
    }
    
    /// Provides contact call feedback
    func contactCall() {
        guard isEnabled else { return }
        
        // Medium feedback for contact calls
        DispatchQueue.main.async {
            self.impactFeedbackGenerator.impactOccurred(intensity: 0.5)
        }
    }
    
    /// Provides emergency call feedback
    func emergencyCall() {
        guard isEnabled else { return }
        
        // Strong feedback for emergency calls
        DispatchQueue.main.async {
            for _ in 0..<2 {
                self.impactFeedbackGenerator.impactOccurred(intensity: 0.8)
                Thread.sleep(forTimeInterval: 0.2)
            }
        }
    }
    
    /// Enables or disables haptic feedback
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
    }
    
    /// Checks if haptic feedback is available on the device
    var isHapticFeedbackAvailable: Bool {
        return UIDevice.current.hasHapticFeedback
    }
    
    // MARK: - Private Methods
    
    private func prepareHapticEngines() {
        // Prepare haptic engines for immediate use
        impactFeedbackGenerator.prepare()
        notificationFeedbackGenerator.prepare()
        selectionFeedbackGenerator.prepare()
    }
    
    private func intensityForStyle(_ style: HapticFeedbackStyle) -> CGFloat {
        switch style {
        case .light:
            return 0.3
        case .medium:
            return 0.5
        case .heavy:
            return 0.8
        case .soft:
            return 0.2
        case .rigid:
            return 0.9
        }
    }
}

// MARK: - Platform-Agnostic Type Definitions

enum HapticFeedbackStyle {
    case light
    case medium
    case heavy
    case soft
    case rigid
}

enum NotificationFeedbackType {
    case success
    case warning
    case error
}

// MARK: - UIDevice Extension

extension UIDevice {
    var hasHapticFeedback: Bool {
        // Check if device supports haptic feedback
        let device = UIDevice.current
        let model = device.model
        
        // iPhone 7 and later support haptic feedback
        if model.contains("iPhone") {
            let systemVersion = device.systemVersion
            if let majorVersion = Int(systemVersion.components(separatedBy: ".").first ?? "0") {
                return majorVersion >= 10 // iOS 10 and later
            }
        }
        
        return false
    }
}

// MARK: - UIKit Type Extensions

extension HapticFeedbackStyle {
    var uiKitStyle: UIImpactFeedbackGenerator.FeedbackStyle {
        switch self {
        case .light:
            return .light
        case .medium:
            return .medium
        case .heavy:
            return .heavy
        case .soft:
            return .soft
        case .rigid:
            return .rigid
        }
    }
}

extension NotificationFeedbackType {
    var uiKitType: UINotificationFeedbackGenerator.FeedbackType {
        switch self {
        case .success:
            return .success
        case .warning:
            return .warning
        case .error:
            return .error
        }
    }
}

// MARK: - Haptic Feedback Types

enum HapticFeedbackType {
    case light
    case medium
    case heavy
    case soft
    case rigid
    case success
    case warning
    case error
    case selection
    case emergency
    case crisis
    case panic
    case stealth
    case navigation
    case button
    case contact
    case flowComplete
    case flowError
}

// MARK: - Haptic Feedback Manager

class HapticFeedbackManager {
    static let shared = HapticFeedbackManager()
    
    private let hapticService = HapticService.shared
    private var feedbackQueue: [HapticFeedbackType] = []
    private var isProcessing = false
    
    private init() {}
    
    /// Queues haptic feedback for processing
    func queueFeedback(_ type: HapticFeedbackType) {
        feedbackQueue.append(type)
        
        if !isProcessing {
            processFeedbackQueue()
        }
    }
    
    /// Processes the feedback queue
    private func processFeedbackQueue() {
        guard !feedbackQueue.isEmpty else {
            isProcessing = false
            return
        }
        
        isProcessing = true
        let feedback = feedbackQueue.removeFirst()
        
        DispatchQueue.main.async {
            self.executeFeedback(feedback)
            
            // Process next feedback after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.processFeedbackQueue()
            }
        }
    }
    
    /// Executes the specified haptic feedback
    private func executeFeedback(_ type: HapticFeedbackType) {
        switch type {
        case .light:
            hapticService.impact(.light)
        case .medium:
            hapticService.impact(.medium)
        case .heavy:
            hapticService.impact(.heavy)
        case .soft:
            hapticService.impact(.soft)
        case .rigid:
            hapticService.impact(.rigid)
        case .success:
            hapticService.notification(.success)
        case .warning:
            hapticService.notification(.warning)
        case .error:
            hapticService.notification(.error)
        case .selection:
            hapticService.selection()
        case .emergency:
            hapticService.emergency()
        case .crisis:
            hapticService.crisisDetected()
        case .panic:
            hapticService.panicButton()
        case .stealth:
            hapticService.stealthMode()
        case .navigation:
            hapticService.navigation()
        case .button:
            hapticService.buttonPress()
        case .contact:
            hapticService.contactCall()
        case .flowComplete:
            hapticService.flowCompleted()
        case .flowError:
            hapticService.flowError()
        }
    }
    
    /// Clears the feedback queue
    func clearQueue() {
        feedbackQueue.removeAll()
        isProcessing = false
    }
    
    /// Gets the current queue size
    var queueSize: Int {
        return feedbackQueue.count
    }
}