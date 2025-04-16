import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct EditCustomerProfileView: View {
    @Environment(\.dismiss) var dismiss

    @State var name: String
    @State var email: String
    @State var phone: String

    @State private var isSaving = false
    @State private var saveError: String?

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 20) {
                Spacer().frame(height: 20)

                HStack {
                    Text("Edit Profile")
                        .font(.largeTitle)
                        .bold()
                    Spacer()
                }

                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Name").font(.caption).foregroundColor(.gray)
                        TextField("Enter name", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Email").font(.caption).foregroundColor(.gray)
                        TextField("Enter email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Phone").font(.caption).foregroundColor(.gray)
                        TextField("Enter phone", text: $phone)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.phonePad)
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

                Spacer()
            }
            .padding()
            .navigationBarBackButtonHidden(true)

            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.gray)
                    .font(.title2)
                    .padding()
            }
        }
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
            "name": name,
            "email": email,
            "phone": phone
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
