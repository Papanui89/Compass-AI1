import SwiftUI
import CoreLocation
import AVFoundation

class LegalViewModel: ObservableObject {
    @Published var scenarios: [LegalScenario] = []
    private let synthesizer = AVSpeechSynthesizer()
    
    init() {
        loadStateSpecificRights()
    }
    
    func loadStateSpecificRights() {
        // TODO: Use location to load state-specific rights
        // For now, use generic scenarios
        scenarios = [
            LegalScenario(
                title: "Police Stop",
                icon: "car.fill",
                scripts: [
                    "I do not consent to a search.",
                    "Am I free to go?",
                    "I wish to remain silent."
                ],
                rights: [
                    "You have the right to remain silent.",
                    "You do not have to consent to a search.",
                    "You have the right to ask if you are free to leave."
                ],
                quickTips: [
                    "Stay calm and respectful",
                    "Don't argue or resist",
                    "Record if safe to do so"
                ]
            ),
            LegalScenario(
                title: "ICE Encounter",
                icon: "person.2.fill",
                scripts: [
                    "I do not wish to answer questions without a lawyer.",
                    "I do not consent to a search."
                ],
                rights: [
                    "You have the right to remain silent.",
                    "You do not have to open the door unless they have a warrant.",
                    "You have the right to speak to a lawyer."
                ],
                quickTips: [
                    "Don't open the door without a warrant",
                    "Ask to see identification",
                    "Call a lawyer immediately"
                ]
            ),
            LegalScenario(
                title: "School Rights",
                icon: "building.2.fill",
                scripts: [
                    "I want to call my parent or guardian.",
                    "I do not consent to a search."
                ],
                rights: [
                    "You have the right to remain silent.",
                    "You have the right to refuse a search of your belongings.",
                    "You have the right to call a parent or guardian."
                ],
                quickTips: [
                    "Ask for a parent to be present",
                    "Don't consent to searches",
                    "Know your school's policies"
                ]
            ),
            LegalScenario(
                title: "Protest",
                icon: "megaphone.fill",
                scripts: [
                    "I am exercising my First Amendment rights.",
                    "I do not consent to a search."
                ],
                rights: [
                    "You have the right to peacefully protest.",
                    "You do not have to consent to a search.",
                    "You have the right to record police in public spaces."
                ],
                quickTips: [
                    "Stay peaceful and non-violent",
                    "Record interactions if safe",
                    "Know your protest location"
                ]
            )
        ]
    }
    
    func readAloud(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }
    
    func stopReading() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}

struct LegalScenario: Identifiable, Equatable, Hashable {
    let id = UUID()
    let title: String
    let icon: String
    let scripts: [String]
    let rights: [String]
    let quickTips: [String]
} 