import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

// MARK: - Data Models

struct Mission: Identifiable {
    let id: String // Firestore-generated ID
    let title: String
    let description: String
    let reward: String
    let imageName: String?  // Optional image name for the mission card
}

struct Restaurant: Identifiable {
    let id: String // Firestore-generated ID
    let name: String
    var missions: [Mission]
}

// MARK: - Mission Card View

struct MissionCard: View {
    let mission: Mission
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 5) {
                Text(mission.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(mission.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(4)
                
                Spacer()
                
                HStack {
                    Text(mission.reward)
                        .font(.caption)
                        .foregroundColor(.yellow)
                        .padding(6)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(8)
                    Spacer()
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            
            Spacer()
            
            if let imageName = mission.imageName, !imageName.isEmpty {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 100)
                    .clipped()
                    .cornerRadius(8)
            }
        }
        .padding()
        .frame(width: 300, height: 160)
        .background(Color.orange)
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}

// MARK: - ViewModel for Missions

class MissionsViewModel: ObservableObject {
    @Published var restaurants: [Restaurant] = []
    
    init() {
        FirebaseApp.configure()
        fetchRestaurants()
    }
    
    func fetchRestaurants() {
        let db = Firestore.firestore()
        db.collection("restaurants").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting restaurants: \(error)")
                return
            }
            
            guard let querySnapshot = querySnapshot else { return }
            
            var fetchedRestaurants: [Restaurant] = []
            
            for document in querySnapshot.documents {
                let restaurantID = document.documentID
                let data = document.data()
                let name = data["name"] as? String ?? ""
                
                let restaurant = Restaurant(id: restaurantID, name: name, missions: [])
                fetchedRestaurants.append(restaurant)
                
                document.reference.collection("missions").getDocuments { (missionsSnapshot, missionsError) in
                    if let missionsError = missionsError {
                        print("Error getting missions: \(missionsError)")
                        return
                    }
                    
                    let missions = missionsSnapshot?.documents.map { missionDoc in
                        let missionData = missionDoc.data()
                        return Mission(
                            id: missionDoc.documentID,
                            title: missionData["title"] as? String ?? "",
                            description: missionData["description"] as? String ?? "",
                            reward: missionData["reward"] as? String ?? "",
                            imageName: missionData["imageName"] as? String ?? ""
                        )
                    } ?? []
                    
                    DispatchQueue.main.async {
                        if let index = fetchedRestaurants.firstIndex(where: { $0.id == restaurantID }) {
                            fetchedRestaurants[index].missions = missions
                        }
                        self.restaurants = fetchedRestaurants
                    }
                }
            }
        }
    }
}

// MARK: - Missions Page View

struct MissionsPageView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = MissionsViewModel()
    let userName: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("Welcome back, \(userName). Let's do some missions!")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                ForEach(viewModel.restaurants) { restaurant in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(restaurant.name)
                            .font(.title2)
                            .bold()
                            .padding(.bottom, 4)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(restaurant.missions) { mission in
                                    MissionCard(mission: mission)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                Spacer()
            }
        }
        .navigationTitle("Missions")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

// MARK: - User Session Persistence

func checkUserSession() -> Bool {
    return Auth.auth().currentUser != nil
}

// MARK: - Preview

struct MissionsPageView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleMissions = [
            Mission(id: UUID().uuidString, title: "Try Our Taco", description: "...", reward: "...", imageName: "taco"),
            Mission(id: UUID().uuidString, title: "Bring a Friend", description: "...", reward: "...", imageName: "food2")
        ]
        let restaurant = Restaurant(id: UUID().uuidString, name: "Oscar's Taco Shop", missions: sampleMissions)
        
        NavigationStack {
            MissionsPageView(userName: "Brian")
        }
    }
}
