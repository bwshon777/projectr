import SwiftUI
import FirebaseFirestore

struct EditMissionView: View {
    @Binding var mission: Mission
    let restaurantId: String

    @State private var showConfirmation = false
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

            Button("Save Changes") {
                updateMission()
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(8)
        }
        .navigationTitle("Edit Mission")
        .alert(isPresented: $showConfirmation) {
            Alert(title: Text("Success"), message: Text("Mission updated!"), dismissButton: .default(Text("OK")) {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    func updateMission() {
        guard let missionId = mission.id else {
            print("Missing mission ID")
            return
        }

        print("🧾 Updating mission \(mission.id ?? "nil") for restaurant \(restaurantId)")

        let db = Firestore.firestore()
        db.collection("restaurants")
            .document(restaurantId)
            .collection("missions")
            .document(mission.id!)
            .updateData([
                "title": mission.title,
                "description": mission.description,
                "reward": mission.reward,
                "expiration": mission.expiration ?? "",
                "status": mission.status,
                "imageUrl": mission.imageUrl ?? ""
            ]) { error in
                if let error = error {
                    print("❌ Error: \(error.localizedDescription)")
                } else {
                    print("✅ Success: Mission updated.")
                    showConfirmation = true
                }
            }
    }
}

