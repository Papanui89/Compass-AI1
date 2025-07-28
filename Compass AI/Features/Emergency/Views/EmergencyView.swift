import SwiftUI

/// Main emergency interface for crisis response
struct EmergencyView: View {
    @StateObject private var viewModel = EmergencyViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.red.opacity(0.1), Color.orange.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Emergency header
                        emergencyHeader
                        
                        // Crisis cards
                        crisisCardsSection
                        
                        // Quick actions
                        quickActionsSection
                        
                        // Emergency contacts
                        emergencyContactsSection
                        
                        // Recent crises
                        recentCrisesSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Emergency")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Settings") {
                        viewModel.showSettings = true
                    }
                }
            }
            .sheet(isPresented: $viewModel.showSettings) {
                EmergencySettingsView()
            }
            .alert("Emergency Alert", isPresented: $viewModel.showEmergencyAlert) {
                Button("Call 911", role: .destructive) {
                    viewModel.callEmergencyServices()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text(viewModel.emergencyAlertMessage)
            }
        }
        .onAppear {
            viewModel.loadEmergencyData()
        }
    }
    
    // MARK: - View Components
    
    private var emergencyHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.red)
            
            Text("Emergency Response")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Quick access to crisis support and emergency services")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var crisisCardsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Crisis Types")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(viewModel.crisisTypes, id: \.self) { crisisType in
                    CrisisCard(crisisType: crisisType) {
                        viewModel.selectCrisisType(crisisType)
                    }
                }
            }
        }
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                QuickActionButton(
                    title: "Panic Button",
                    icon: "exclamationmark.triangle.fill",
                    color: .red
                ) {
                    viewModel.activatePanicMode()
                }
                
                QuickActionButton(
                    title: "Quick Exit",
                    icon: "arrow.up.right.square.fill",
                    color: .orange
                ) {
                    viewModel.quickExit()
                }
                
                QuickActionButton(
                    title: "Stealth Mode",
                    icon: "eye.slash.fill",
                    color: .purple
                ) {
                    viewModel.activateStealthMode()
                }
            }
        }
    }
    
    private var emergencyContactsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Emergency Contacts")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Add") {
                    viewModel.showAddContact = true
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            if viewModel.emergencyContacts.isEmpty {
                Text("No emergency contacts added")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            } else {
                ForEach(viewModel.emergencyContacts) { contact in
                    EmergencyContactRow(contact: contact) {
                        viewModel.callContact(contact)
                    }
                }
            }
        }
    }
    
    private var recentCrisesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Crises")
                .font(.headline)
                .fontWeight(.semibold)
            
            if viewModel.recentCrises.isEmpty {
                Text("No recent crisis events")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            } else {
                ForEach(viewModel.recentCrises) { crisis in
                    RecentCrisisRow(crisis: crisis) {
                        viewModel.viewCrisisDetails(crisis)
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct CrisisCard: View {
    let crisisType: CrisisType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: crisisType.icon)
                    .font(.title2)
                    .foregroundColor(crisisType.priority.color)
                
                Text(crisisType.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(8)
            .shadow(radius: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(8)
            .shadow(radius: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmergencyContactRow: View {
    let contact: EmergencyContact
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(contact.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    if let relationship = contact.relationship {
                        Text(relationship)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(contact.phoneNumber)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    
                    if contact.isPrimary {
                        Text("Primary")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(8)
            .shadow(radius: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RecentCrisisRow: View {
    let crisis: Crisis
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(crisis.type.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(crisis.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(crisis.severity.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(crisis.severity.uiColor)
                    
                    Text(crisis.status.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(8)
            .shadow(radius: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Extensions

extension CrisisType {
    var icon: String {
        switch self {
        case .suicide:
            return "heart.slash"
        case .domesticViolence:
            return "house.slash"
        case .medicalEmergency:
            return "cross.case"
        case .mentalHealth:
            return "brain.head.profile"
        case .substanceAbuse:
            return "pills"
        case .naturalDisaster:
            return "tornado"
        case .violence:
            return "exclamationmark.shield"
        case .abuse:
            return "person.slash"
        case .harassment:
            return "message.slash"
        case .other:
            return "exclamationmark.triangle"
        }
    }
}

extension CrisisPriority {
    var color: Color {
        switch self {
        case .low:
            return .green
        case .medium:
            return .yellow
        case .high:
            return .orange
        case .immediate:
            return .red
        }
    }
}

extension CrisisSeverity {
    var uiColor: Color {
        switch self {
        case .low:
            return .green
        case .medium:
            return .yellow
        case .high:
            return .orange
        case .critical:
            return .red
        }
    }
}

// MARK: - Preview

struct EmergencyView_Previews: PreviewProvider {
    static var previews: some View {
        EmergencyView()
    }
} 