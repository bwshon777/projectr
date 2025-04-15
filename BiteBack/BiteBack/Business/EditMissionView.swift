import SwiftUI
import FirebaseFirestore

struct EditMissionView: View {
    @Binding var mission: Mission
    let restaurantId: String

    @State private var showUpdateConfirmation = false
    @State private var showDeleteConfirmation = false
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Back Button
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.gray)
                        .padding()
                }

                Text("Edit Mission")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)

                GroupBox(label: Text("Mission Details").font(.headline)) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Title").font(.subheadline).foregroundColor(.gray)
                        TextField("Enter mission title", text: $mission.title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Text("Description").font(.subheadline).foregroundColor(.gray)
                        TextField("Enter mission description", text: $mission.description)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Text("Reward").font(.subheadline).foregroundColor(.gray)
                        TextField("Enter reward", text: $mission.reward)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Text("Expiration").font(.subheadline).foregroundColor(.gray)
                        TextField("YYYY-MM-DD", text: Binding(get: { mission.expiration ?? "" }, set: { mission.expiration = $0 }))
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Text("Status").font(.subheadline).foregroundColor(.gray)
                        TextField("e.g. active", text: $mission.status)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }

                GroupBox(label: Text("Mission Steps").font(.headline)) {
                    if !mission.steps.isEmpty {
                        ForEach(mission.steps.indices, id: \.self) { index in
                            HStack {
                                Text("Step \(index + 1)").foregroundColor(.gray)
                                TextField("Enter step", text: $mission.steps[index])
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                Button(action: {
                                    mission.steps.remove(at: index)
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    Button(action: {
                        mission.steps.append("")
                    }) {
                        Label("Add Step", systemImage: "plus.circle.fill")
                            .foregroundColor(Color(red: 0.0, green: 0.698, blue: 1.0))
                    }
                }

                HStack(spacing: 16) {
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
            }
            .padding()
        }
        .alert(isPresented: $showUpdateConfirmation) {
            Alert(title: Text("Success"), message: Text("Mission updated!"), dismissButton: .default(Text("OK")) {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(title: Text("Are you sure?"), message: Text("This will permanently delete the mission."), primaryButton: .destructive(Text("Delete"), action: deleteMission), secondaryButton: .cancel())
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
            "steps": mission.steps
        ]) { _ in
            dismiss()
        }
    }

    func deleteMission() {
        guard let missionId = mission.id else { return }
        let db = Firestore.firestore()
        db.collection("restaurants").document(restaurantId).collection("missions").document(missionId).delete { _ in
            presentationMode.wrappedValue.dismiss()
        }
    }
}
