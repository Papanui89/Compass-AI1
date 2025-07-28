import SwiftUI

class EmergencyContactsViewModel: ObservableObject {
    @Published var emergencyServices: [ContactRowData] = [
        ContactRowData(icon: "phone.fill", color: .red, name: "911", subtitle: "Police, Fire, Medical", phone: "911"),
        ContactRowData(icon: "phone.fill", color: .purple, name: "988", subtitle: "Suicide & Crisis Lifeline", phone: "988"),
        ContactRowData(icon: "message.fill", color: .blue, name: "Crisis Text Line", subtitle: "Text HELLO to 741741", phone: "741741")
    ]
    @Published var personalContacts: [ContactRowData] = [
        ContactRowData(icon: "person.crop.circle.fill", color: .green, name: "Mom", subtitle: "Parent", phone: "5551234567"),
        ContactRowData(icon: "person.crop.circle.fill", color: .green, name: "Best Friend", subtitle: "Friend", phone: "5559876543")
    ]
    @Published var specializedHelp: [ContactRowData] = [
        ContactRowData(icon: "phone.fill", color: .orange, name: "Domestic Violence Hotline", subtitle: "1-800-799-7233", phone: "18007997233"),
        ContactRowData(icon: "phone.fill", color: .teal, name: "Poison Control", subtitle: "1-800-222-1222", phone: "18002221222")
    ]
    
    func addPersonalContact() {
        // TODO: Show add contact UI
    }
    
    func deletePersonalContact(at offsets: IndexSet) {
        personalContacts.remove(atOffsets: offsets)
    }
}

struct ContactRowData: Identifiable {
    let id = UUID()
    let icon: String
    let color: Color
    let name: String
    let subtitle: String?
    let phone: String
} 