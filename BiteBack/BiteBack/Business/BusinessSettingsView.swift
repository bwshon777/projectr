import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct BusinessSettingsView: View {
    @State private var businessName: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var mode: String = ""
    @State private var street: String = ""
    @State private var city: String = ""
    @State private var state: String = ""

    @Environment(\.dismiss) var dismiss
    @State private var showLogoutConfirmation = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Header
                ZStack(alignment: .bottom) {
                    LinearGradient(
                        gradient: Gradient(colors: [Color(red: 0.0, green: 0.698, blue: 1.0)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 200)
                    .clipShape(RoundedCornerShape(corners: [.bottomLeft, .bottomRight], radius: 40))
                    .ignoresSafeArea(edges: .top)

                    Text("Your Profile!")
                        .font(.title)
                        .foregroundColor(.white)
                        .bold()
                        .padding(.bottom, 80)
                }

                Spacer().frame(height: 50)

                // MARK: - Info Card
                VStack(spacing: 16) {
                    ProfileRow(icon: "building.2.fill", label: businessName)
                    ProfileRow(icon: "envelope.fill", label: email)
                    ProfileRow(icon: "phone.fill", label: phone)
                    ProfileRow(icon: "person.2.fill", label: mode.capitalized)
                    ProfileRow(icon: "mappin.and.ellipse", label: street)
                    ProfileRow(icon: "location.fill", label: "\(city), \(state)")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 4)
                .padding(.horizontal)

                Spacer()
                
                // MARK: - Buttons
                VStack(spacing: 12) {
                    NavigationLink(destination: EditBusinessSettingsView(
                        businessName: businessName,
                        email: email,
                        phone: phone,
                        street: street,
                        city: city,
                        state: state
                    )) {
                        Text("Edit Profile")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 0.0, green: 0.698, blue: 1.0))
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }

                    Button(action: {
                        showLogoutConfirmation = true
                    }) {
                        Text("Log Out")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .accentColor(.blue)
            .onAppear(perform: loadUserData)
            .alert(isPresented: $showLogoutConfirmation) {
                Alert(
                    title: Text("Log Out"),
                    message: Text("Are you sure you want to log out?"),
                    primaryButton: .destructive(Text("Log Out")) {
                        logout()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    // MARK: - Reusable Row
    struct ProfileRow: View {
        let icon: String
        let label: String

        var body: some View {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(Color(red: 0.0, green: 0.698, blue: 1.0))
                    .font(.title3)
                    .frame(width: 30)

                Text(label)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primary)

                Spacer()
            }
        }
    }

    
    func loadUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(userId)

        docRef.getDocument { document, error in
            if let data = document?.data() {
                self.businessName = data["businessName"] as? String ?? ""
                self.email = data["email"] as? String ?? ""
                self.phone = data["phone"] as? String ?? ""
                self.mode = data["mode"] as? String ?? ""
                self.street = data["businessStreet"] as? String ?? ""
                self.city = data["businessCity"] as? String ?? ""
                self.state = data["businessState"] as? String ?? ""
            }
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            dismiss()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
