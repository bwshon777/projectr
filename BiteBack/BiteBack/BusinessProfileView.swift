import SwiftUI
import FirebaseFirestore

struct BusinessProfileView: View {
    var businessName: String
    @State private var missions: [Mission] = []
    @State private var restaurantId: String = ""

    var body: some View {
            VStack {
                // Business Header
                Text(businessName)
                    .font(.title)
                    .bold()

                Divider()
                    .padding(.bottom)

                Text("Your Missions")
                    .font(.headline)
                    .padding(.bottom, 5)

                // Missions List
                List {
                    ForEach($missions) { $mission in
                        NavigationLink(
                            destination: EditMissionView(mission: $mission, restaurantId: getRestaurantId())
                        ) {
                            VStack(alignment: .leading) {
                                Text(mission.title)
                                    .font(.headline)
                                Text(mission.description)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("Reward: \(mission.reward)")
                                    .font(.footnote)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }

                // Add New Mission Button
                NavigationLink(destination: AddMissionView()) {
                    Text("Add New Mission")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.0, green: 0.698, blue: 1.0))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                }
            }
            .onAppear {
                fetchBusinessMissions()
            }
            
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
        }
    

    // MARK: - Firestore Fetch Logic

    func fetchBusinessMissions() {
        let db = Firestore.firestore()

        db.collection("restaurants")
            .whereField("name", isEqualTo: businessName)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error finding restaurant: \(error.localizedDescription)")
                    return
                }

                guard let document = snapshot?.documents.first else {
                    print("No restaurant found for \(businessName)")
                    return
                }

                self.restaurantId = document.documentID

                db.collection("restaurants")
                    .document(self.restaurantId)
                    .collection("missions")
                    .getDocuments { missionSnapshot, error in
                        if let error = error {
                            print("Error fetching missions: \(error.localizedDescription)")
                            return
                        }

                        guard let missionDocs = missionSnapshot?.documents else { return }

                        missions = missionDocs.compactMap { doc in
                            let data = doc.data()
                            return Mission(
                                id: doc.documentID,
                                title: data["title"] as? String ?? "",
                                description: data["description"] as? String ?? "",
                                reward: data["reward"] as? String ?? "",
                                expiration: data["expiration"] as? String,
                                imageUrl: data["imageUrl"] as? String,
                                status: data["status"] as? String ?? "active"
                            )
                        }
                    }
            }
    }

    // Now returns the fetched restaurant ID
    func getRestaurantId() -> String {
        return restaurantId
    }
}


