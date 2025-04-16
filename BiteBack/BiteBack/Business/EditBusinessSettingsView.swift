import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct EditBusinessSettingsView: View {
    @Environment(\.dismiss) var dismiss

    @State var businessName: String
    @State var email: String
    @State var phone: String
    @State var street: String
    @State var city: String
    @State var state: String

    @State private var isSaving = false
    @State private var saveError: String?

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding(.horizontal)

            HStack {
                Text("Edit Profile")
                    .font(.largeTitle)
                    .bold()
                Spacer()
            }
            .padding(.horizontal)

            VStack(spacing: 16) {
                Group {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Business Name")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("Enter business name", text: $businessName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Email")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("Enter email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Phone")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("Enter phone number", text: $phone)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Street")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("Enter street address", text: $street)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("City")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("Enter city", text: $city)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("State")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("Enter state", text: $state)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
            }
            .padding()

            if let error = saveError {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

            Button(action: saveChanges) {
                if isSaving {
                    ProgressView()
                } else {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.0, green: 0.698, blue: 1.0))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .disabled(isSaving)
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }

    func saveChanges() {
        guard let userId = Auth.auth().currentUser?.uid else {
            saveError = "User not logged in"
            return
        }

        isSaving = true
        saveError = nil

        let db = Firestore.firestore()
        let data: [String: Any] = [
            "businessName": businessName,
            "email": email,
            "phone": phone,
            "businessStreet": street,
            "businessCity": city,
            "businessState": state
        ]

        db.collection("users").document(userId).updateData(data) { error in
            isSaving = false
            if let error = error {
                saveError = "Failed to save changes: \(error.localizedDescription)"
            } else {
                dismiss()
            }
        }
    }
}
