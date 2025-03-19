import SwiftUI
import FirebaseFirestore

struct EditMissionView: View {
    @Binding var mission: Mission
    let restaurantId: String

    @State private var showUpdateConfirmation = false
    @State private var showDeleteConfirmation = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Mission Details")) {
                    TextField("Title", text: $mission.title)
                    TextField("Description", text: $mission.description)
                    TextField("Reward", text: $mission.reward)
                    TextField("Expiration", text: Binding<String>(
                        get: { mission.expiration ?? "" },
                        set: { mission.expiration = $0 }
                    ))
                    TextField("Status", text: $mission.status)
                }
            }
            .navigationTitle("Edit Mission")
            .navigationBarTitleDisplayMode(.inline)

            VStack(spacing: 16) {
                Button(action: updateMission) {
                    Text("Save Changes")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.0, green: 0.698, blue: 1.0))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: {
                    showDeleteConfirmation = true
                }) {
                    Text("Delete Mission")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .alert(isPresented: $showUpdateConfirmation) {
            Alert(title: Text("Success"),
                  message: Text("Mission updated!"),
                  dismissButton: .default(Text("OK")) {
                      presentationMode.wrappedValue.dismiss()
                  })
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(title: Text("Are you sure?"),
                  message: Text("This will permanently delete the mission."),
                  primaryButton: .destructive(Text("Delete"), action: deleteMission),
                  secondaryButton: .cancel())
        }
    }

    // MARK: - Update Firebase

    func updateMission() {
        guard let missionId = mission.id else {
            print("Missing mission ID")
            return
        }

        let db = Firestore.firestore()
        db.collection("restaurants")
            .document(restaurantId)
            .collection("missions")
            .document(missionId)
            .updateData([
                "title": mission.title,
                "description": mission.description,
                "reward": mission.reward,
                "expiration": mission.expiration ?? "",
                "status": mission.status,
                "imageUrl": mission.imageUrl ?? ""
            ]) { error in
                if let error = error {
                    print("❌ Error updating mission: \(error.localizedDescription)")
                } else {
                    print("✅ Mission updated successfully.")
                    showUpdateConfirmation = true
                }
            }
    }

    func deleteMission() {
        guard let missionId = mission.id else {
            print("Missing mission ID")
            return
        }

        let db = Firestore.firestore()
        db.collection("restaurants")
            .document(restaurantId)
            .collection("missions")
            .document(missionId)
            .delete { error in
                if let error = error {
                    print("❌ Error deleting mission: \(error.localizedDescription)")
                } else {
                    print("🗑️ Mission deleted successfully.")
                    presentationMode.wrappedValue.dismiss()
                }
            }
    }
}

