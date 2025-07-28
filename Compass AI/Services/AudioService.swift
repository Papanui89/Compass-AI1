import AVFoundation
import SwiftUI

class AudioService: ObservableObject {
    static let shared = AudioService()
    
    @Published var isPlaying = false
    private var audioPlayer: AVAudioPlayer?
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func playSound(named soundName: String, ofType type: String = "mp3") {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: type) else {
            print("Sound file not found: \(soundName).\(type)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("Failed to play sound: \(error)")
        }
    }
    
    func stopSound() {
        audioPlayer?.stop()
        isPlaying = false
    }
    
    func playHapticSound() {
        // iOS-specific haptic sound
        playSound(named: "haptic_sound", ofType: "wav")
    }
    
    func playEmergencySound() {
        // Play emergency alert sound
        playSound(named: "emergency_alert", ofType: "wav")
    }
} 