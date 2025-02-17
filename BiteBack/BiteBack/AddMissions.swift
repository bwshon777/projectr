//
//  AddMissions.swift
//  BiteBack
//
//  Created by Nicholas Pacella on 2/16/25.
//

import SwiftUI
import FirebaseFirestore

struct AddMissionView: View {
    @State private var restaurantName: String = ""
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var reward: String = ""
    @State private var expiration: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Restaurant Details")) {
                    TextField("Restaurant Name", text: $restaurantName)
                }
                
                Section(header: Text("Mission Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                    TextField("Reward", text: $reward)
                    TextField("Expiration Date (YYYY-MM-DD)", text: $expiration)
                }

                Button(action: addMission) {
                    Text("Add Mission")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(restaurantName.isEmpty || title.isEmpty || description.isEmpty || reward.isEmpty || expiration.isEmpty)
            }
            .navigationTitle("Create a Mission")
        }
    }

    func addMission() {
        let db = Firestore.firestore()
        let restaurantRef = db.collection("restaurants")

        // Query Firestore to check if the restaurant already exists
        restaurantRef.whereField("name", isEqualTo: restaurantName).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error checking restaurant: \(error.localizedDescription)")
                return
            }

            if let snapshot = snapshot, !snapshot.documents.isEmpty {
                // Restaurant exists, use its document ID
                let existingRestaurantId = snapshot.documents.first!.documentID
                addMissionToRestaurant(restaurantId: existingRestaurantId)
            } else {
                // Restaurant does not exist, create it first
                let newRestaurantRef = restaurantRef.document()
                newRestaurantRef.setData(["name": restaurantName]) { error in
                    if let error = error {
                        print("Error creating restaurant: \(error.localizedDescription)")
                    } else {
                        print("New restaurant created!")
                        addMissionToRestaurant(restaurantId: newRestaurantRef.documentID)
                    }
                }
            }
        }
    }

    func addMissionToRestaurant(restaurantId: String) {
        let db = Firestore.firestore()
        let missionRef = db.collection("restaurants").document(restaurantId).collection("missions").document()

        let missionData: [String: Any] = [
            "title": title,
            "description": description,
            "reward": reward,
            "expiration": expiration,
            "status": "active"
        ]

        missionRef.setData(missionData) { error in
            if let error = error {
                print("Error adding mission: \(error.localizedDescription)")
            } else {
                print("Mission successfully added!")
                clearForm()
            }
        }
    }

    func clearForm() {
        restaurantName = ""
        title = ""
        description = ""
        reward = ""
        expiration = ""
    }
}

struct AddMissionView_Previews: PreviewProvider {
    static var previews: some View {
        AddMissionView()
    }
}
