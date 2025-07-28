import SwiftUI

struct EmergencyContactsView: View {
    @StateObject private var viewModel = EmergencyContactsViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                // Emergency Services
                Section(header: Text("Emergency Services")) {
                    ForEach(viewModel.emergencyServices) { contact in
                        ContactRow(contact: contact)
                    }
                }
                // Personal Contacts
                Section(header: Text("Personal Contacts")) {
                    ForEach(viewModel.personalContacts) { contact in
                        ContactRow(contact: contact)
                    }
                    .onDelete(perform: viewModel.deletePersonalContact)
                    Button(action: viewModel.addPersonalContact) {
                        Label("Add Contact", systemImage: "plus.circle")
                    }
                }
                // Specialized Help
                Section(header: Text("Specialized Help")) {
                    ForEach(viewModel.specializedHelp) { contact in
                        ContactRow(contact: contact)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Who to Call")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct ContactRow: View {
    let contact: EmergencyContact
    
    var body: some View {
        Button(action: {
            if let url = URL(string: "tel://\(contact.phone)") {
                UIApplication.shared.open(url)
            }
        }) {
            HStack {
                Image(systemName: contact.icon)
                    .foregroundColor(contact.color)
                    .frame(width: 32)
                VStack(alignment: .leading) {
                    Text(contact.name)
                        .font(.headline)
                    if let subtitle = contact.subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                Image(systemName: "phone.fill")
                    .foregroundColor(.blue)
            }
            .padding(.vertical, 6)
        }
    }
}

#Preview {
    EmergencyContactsView()
} 