import SwiftUI

struct ResourcesView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Crisis Resources
                    ResourceSection(
                        title: "Crisis Resources",
                        resources: [
                            Resource(
                                title: "988 Suicide & Crisis Lifeline",
                                subtitle: "24/7 free, confidential support",
                                phone: "988",
                                icon: "phone.circle.fill",
                                color: .red
                            ),
                            Resource(
                                title: "Crisis Text Line",
                                subtitle: "Text HOME to 741741",
                                phone: nil,
                                icon: "message.circle.fill",
                                color: .blue
                            ),
                            Resource(
                                title: "Trevor Project (LGBTQ+)",
                                subtitle: "1-866-488-7386",
                                phone: "1-866-488-7386",
                                icon: "heart.circle.fill",
                                color: .purple
                            )
                        ]
                    )
                    
                    // Mental Health Resources
                    ResourceSection(
                        title: "Mental Health Support",
                        resources: [
                            Resource(
                                title: "National Alliance on Mental Illness",
                                subtitle: "1-800-950-NAMI",
                                phone: "1-800-950-6264",
                                icon: "brain.head.profile",
                                color: .green
                            ),
                            Resource(
                                title: "SAMHSA Helpline",
                                subtitle: "1-800-662-HELP",
                                phone: "1-800-662-4357",
                                icon: "cross.circle.fill",
                                color: .orange
                            )
                        ]
                    )
                    
                    // School & Bullying Resources
                    ResourceSection(
                        title: "School & Bullying Help",
                        resources: [
                            Resource(
                                title: "StopBullying.gov",
                                subtitle: "Federal anti-bullying resources",
                                phone: nil,
                                icon: "shield.circle.fill",
                                color: .blue
                            ),
                            Resource(
                                title: "PACER's National Bullying Prevention Center",
                                subtitle: "1-952-838-9000",
                                phone: "1-952-838-9000",
                                icon: "person.2.circle.fill",
                                color: .purple
                            )
                        ]
                    )
                    
                    // Legal Resources
                    ResourceSection(
                        title: "Legal Help",
                        resources: [
                            Resource(
                                title: "ACLU",
                                subtitle: "Know your rights",
                                phone: nil,
                                icon: "doc.text.circle.fill",
                                color: .blue
                            ),
                            Resource(
                                title: "National Center for Youth Law",
                                subtitle: "Legal help for youth",
                                phone: nil,
                                icon: "building.2.circle.fill",
                                color: .orange
                            )
                        ]
                    )
                    
                    // Emergency Services
                    ResourceSection(
                        title: "Emergency Services",
                        resources: [
                            Resource(
                                title: "911",
                                subtitle: "Emergency services",
                                phone: "911",
                                icon: "exclamationmark.triangle.circle.fill",
                                color: .red
                            ),
                            Resource(
                                title: "Poison Control",
                                subtitle: "1-800-222-1222",
                                phone: "1-800-222-1222",
                                icon: "pills.circle.fill",
                                color: .orange
                            )
                        ]
                    )
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
            .navigationTitle("Resources")
            .navigationBarTitleDisplayMode(.large)
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

// MARK: - Resource Section
struct ResourceSection: View {
    let title: String
    let resources: [Resource]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                ForEach(resources, id: \.title) { resource in
                    ResourceRow(resource: resource)
                }
            }
        }
    }
}

// MARK: - Resource Row
struct ResourceRow: View {
    let resource: Resource
    
    var body: some View {
        Button(action: {
            if let phone = resource.phone {
                makePhoneCall(to: phone)
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: resource.icon)
                    .font(.system(size: 24))
                    .foregroundColor(resource.color)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(resource.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(resource.subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if resource.phone != nil {
                    Image(systemName: "phone.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.green)
                }
            }
            .padding(16)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func makePhoneCall(to phoneNumber: String) {
        if let url = URL(string: "tel:\(phoneNumber)") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Resource Model
struct Resource {
    let title: String
    let subtitle: String
    let phone: String?
    let icon: String
    let color: Color
}

// MARK: - Preview
struct ResourcesView_Previews: PreviewProvider {
    static var previews: some View {
        ResourcesView()
    }
} 