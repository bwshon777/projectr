import SwiftUI
import FirebaseFirestore

struct EditMissionView: View {
    @Binding var mission: Mission
    let restaurantId: String

    @State private var showUpdateConfirmation = false
    @State private var showDeleteConfirmation = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
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

            Section {
                Button("Save Changes") {
                    updateMission()
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(8)

                Button("Delete Mission") {
                    showDeleteConfirmation = true
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.red)
                .cornerRadius(8)
            }
        }
        .navigationTitle("Edit Mission")
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $showUpdateConfirmation) {
            Alert(
                title: Text("Success"),
                message: Text("Mission updated!"),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Delete Mission"),
                message: Text("Are you sure you want to delete this mission?"),
                primaryButton: .destructive(Text("Delete")) {
                    deleteMission()
                },
                secondaryButton: .cancel()
            )
        }
    }

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
                    print("❌ Error updating: \(error.localizedDescription)")
                } else {
                    print("✅ Success: Mission updated.")
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
                    print("❌ Error deleting: \(error.localizedDescription)")
                } else {
                    print("🗑️ Mission deleted.")
                    presentationMode.wrappedValue.dismiss()
                }
            }
    }
}

