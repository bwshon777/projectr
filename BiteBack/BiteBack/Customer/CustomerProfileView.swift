import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CustomerProfileView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var mode: String = ""

    @Environment(\.dismiss) var dismiss
    @State private var showLogoutConfirmation = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 25) {
                // Title
                Text("Your Profile")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 30)

                // Profile Card
                VStack(spacing: 16) {
                    ProfileRow(icon: "person.fill", label: name)
                    ProfileRow(icon: "envelope.fill", label: email)
                    ProfileRow(icon: "phone.fill", label: phone)
                    ProfileRow(icon: "person.2.fill", label: mode.capitalized)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 4)
                .padding(.horizontal)

                // Edit Profile
                NavigationLink(destination: EditCustomerProfileView(name: name, email: email, phone: phone)) {
                    Text("Edit Profile")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                // Log Out
                Button(action: {
                    showLogoutConfirmation = true
                }) {
                    Text("Log Out")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.bottom)
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

    func loadUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(userId)

        docRef.getDocument { document, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }

            if let data = document?.data() {
                self.name = data["name"] as? String ?? ""
                self.email = data["email"] as? String ?? ""
                self.phone = data["phone"] as? String ?? ""
                self.mode = data["mode"] as? String ?? ""
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

struct ProfileRow: View {
    let icon: String
    let label: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.title3)
                .frame(width: 30)

            Text(label)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.primary)

            Spacer()
        }
    }
}
