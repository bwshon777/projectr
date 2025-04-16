import SwiftUI
import FirebaseFirestore

struct EditMissionView: View {
    @Binding var mission: Mission
    @Binding var shouldDismissToBusiness: Bool
    
    let restaurantId: String

    @Environment(\.dismiss) var dismiss

    @State private var showUpdateConfirmation = false
    @State private var showDeleteConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Custom Back Button
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.gray)
            }

            Text("Edit Mission")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 5)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    GroupBox(label: Text("MISSION DETAILS").fontWeight(.bold)) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title").font(.caption).foregroundColor(.gray)
                            TextField("Enter mission title", text: $mission.title)
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                            Text("Description").font(.caption).foregroundColor(.gray)
                            TextField("Enter mission description", text: $mission.description)
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                            Text("Reward").font(.caption).foregroundColor(.gray)
                            TextField("Enter reward", text: $mission.reward)
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                            Text("Expiration Date").font(.caption).foregroundColor(.gray)
                            TextField("YYYY-MM-DD", text: Binding(get: { mission.expiration ?? "" }, set: { mission.expiration = $0 }))
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                            Text("Status").font(.caption).foregroundColor(.gray)
                            TextField("e.g. active", text: $mission.status)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding(.top, 6)
                    }

                    GroupBox(label: Text("MISSION STEPS").fontWeight(.bold)) {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(mission.steps.indices, id: \.self) { index in
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Step \(index + 1)")
                                        .font(.caption)
                                        .foregroundColor(.gray)

                                    TextField("Enter step description", text: $mission.steps[index].description)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())

                                    TextField("Optional link (e.g., Instagram, Yelp)", text: $mission.steps[index].link)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())

                                    if mission.steps.count > 1 {
                                        Button(action: {
                                            mission.steps.remove(at: index)
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                            }

                            HStack {
                                Spacer()
                                Button(action: {
                                    mission.steps.append(MissionStep(description: "", link: ""))
                                }) {
                                    Label("Add Step", systemImage: "plus.circle.fill")
                                        .foregroundColor(Color(red: 0.0, green: 0.698, blue: 1.0))
                                }
                                Spacer()
                            }
                            .padding(.top, 6)
                        }
                        .padding(.top, 6)
                    }

                    HStack(spacing: 16) {
                        Button(action: updateMission) {
                            Text("Save Changes")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(red: 0.0, green: 0.698, blue: 1.0))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }

                        Button(action: { showDeleteConfirmation = true }) {
                            Text("Delete Mission")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                }
            }
        }
        .padding()
        .alert("Success", isPresented: $showUpdateConfirmation) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Mission updated!")
        }
        .alert("Are you sure?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive, action: deleteMission)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete the mission.")
        }
        .navigationBarBackButtonHidden(true)
    }

    func updateMission() {
        guard let missionId = mission.id else { return }
        let db = Firestore.firestore()
        db.collection("restaurants").document(restaurantId).collection("missions").document(missionId).updateData([
            "title": mission.title,
            "description": mission.description,
            "reward": mission.reward,
            "expiration": mission.expiration ?? "",
            "status": mission.status,
            "imageUrl": mission.imageUrl ?? "",
            "steps": mission.steps.map { ["description": $0.description, "link": $0.link] }
        ]) { _ in
            showUpdateConfirmation = true
        }
    }

    func deleteMission() {
        guard let missionId = mission.id else { return }
        let db = Firestore.firestore()
        db.collection("restaurants").document(restaurantId).collection("missions").document(missionId).delete { _ in
            shouldDismissToBusiness = true
            dismiss()
        }
    }
}
