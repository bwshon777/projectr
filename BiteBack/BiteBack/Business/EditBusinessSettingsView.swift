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

            Text("Edit Profile")
                .font(.largeTitle)
                .bold()

            VStack(spacing: 16) {
                TextField("Business Name", text: $businessName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Phone", text: $phone)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Street", text: $street)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("City", text: $city)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("State", text: $state)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
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
                        .background(Color.blue)
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

