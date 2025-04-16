import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CustomerProfileView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var mode: String = ""
    @State private var showLogoutConfirmation = false
    @Environment(\.dismiss) var dismiss
    @State private var missionsCompleted: Int = 0
    @State private var rewardsRedeemed: Int = 0

    var body: some View {
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

                Text("Your Profile")
                    .font(.title)
                    .foregroundColor(.white)
                    .bold()
                    .padding(.bottom, 80)
            }

            // MARK: - Info Card (moved up here)
            VStack(spacing: 16) {
                ProfileRow(icon: "person.fill", label: name)
                ProfileRow(icon: "envelope.fill", label: email)
                ProfileRow(icon: "phone.fill", label: phone)
                ProfileRow(icon: "person.2.fill", label: mode.capitalized)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 4)
            .padding(.horizontal)
            .padding(.top, -40)

            // MARK: - Mission Stats
            HStack {
                VStack(spacing: 4) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                    Text("Missions Completed")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(missionsCompleted)")
                        .font(.headline)
                }

                Spacer()

                VStack(spacing: 4) {
                    Image(systemName: "gift.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                    Text("Rewards Redeemed")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(rewardsRedeemed)")
                        .font(.headline)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            .padding(.horizontal)
            .padding(.top, 16)

            Spacer()

            // MARK: - Buttons
            VStack(spacing: 12) {
                NavigationLink(destination: EditCustomerProfileView(name: name, email: email, phone: phone)) {
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


    func loadUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        // Load basic user data
        db.collection("users").document(userId).getDocument { document, error in
            if let data = document?.data() {
                self.name = data["name"] as? String ?? ""
                self.email = data["email"] as? String ?? ""
                self.phone = data["phone"] as? String ?? ""
                self.mode = data["mode"] as? String ?? ""
            }
        }

        // Load mission stats
        db.collection("users").document(userId)
            .collection("completedMissions")
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                self.missionsCompleted = documents.count
                self.rewardsRedeemed = documents.filter {
                    ($0["redeemed"] as? Bool) == true
                }.count
            }
    }

    func logout() {
        try? Auth.auth().signOut()
        dismiss()
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

// MARK: - Rounded Corner Shape
struct RoundedCornerShape: Shape {
    var corners: UIRectCorner
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Hex Color Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        r = Double((int >> 16) & 0xFF) / 255
        g = Double((int >> 8) & 0xFF) / 255
        b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
