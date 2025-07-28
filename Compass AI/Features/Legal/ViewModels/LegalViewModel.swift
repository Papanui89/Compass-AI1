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
                scripts: [
                    "I do not consent to a search.",
                    "Am I free to go?",
                    "I wish to remain silent."
                ],
                rights: [
                    "You have the right to remain silent.",
                    "You do not have to consent to a search.",
                    "You have the right to ask if you are free to leave."
                ]
            ),
            LegalScenario(
                title: "ICE Encounter",
                scripts: [
                    "I do not wish to answer questions without a lawyer.",
                    "I do not consent to a search."
                ],
                rights: [
                    "You have the right to remain silent.",
                    "You do not have to open the door unless they have a warrant.",
                    "You have the right to speak to a lawyer."
                ]
            ),
            LegalScenario(
                title: "School Rights",
                scripts: [
                    "I want to call my parent or guardian.",
                    "I do not consent to a search."
                ],
                rights: [
                    "You have the right to remain silent.",
                    "You have the right to refuse a search of your belongings.",
                    "You have the right to call a parent or guardian."
                ]
            ),
            LegalScenario(
                title: "Protest",
                scripts: [
                    "I am exercising my First Amendment rights.",
                    "I do not consent to a search."
                ],
                rights: [
                    "You have the right to peacefully protest.",
                    "You do not have to consent to a search.",
                    "You have the right to record police in public spaces."
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
    let scripts: [String]
    let rights: [String]
} 