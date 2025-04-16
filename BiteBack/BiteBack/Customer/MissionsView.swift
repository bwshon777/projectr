import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

struct Mission: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var reward: String
    var expiration: String?
    var imageUrl: String?
    var status: String
    var steps: [MissionStep] 
    var restaurantId: String?
}

struct Restaurant: Identifiable {
    let id = UUID()
    let name: String
    let missions: [Mission]
}

struct MissionCard: View {
    let mission: Mission
    let backgroundColor: Color
    let statusText: String?
    let isDimmed: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(mission.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)

                    Text("\u{1F525} \(mission.steps.count) step\(mission.steps.count == 1 ? "" : "s")")
                        .font(.subheadline)
                        .foregroundColor(.red)

                    Text(mission.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }

                Spacer()

                if let urlStr = mission.imageUrl, let url = URL(string: urlStr) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipped()
                            .cornerRadius(10)
                    } placeholder: {
                        Color.gray.frame(width: 80, height: 80).cornerRadius(10)
                    }
                }
            }
            .padding()
            .background(backgroundColor)
            .cornerRadius(20)
            .shadow(radius: 3)
            .opacity(isDimmed ? 0.4 : 1.0)

            if let status = statusText {
                Text(status)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(status == "REDEEMED" ? Color.red : Color.black.opacity(0.75))
                    .clipShape(Capsule())
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(8)
            }
        }
    }
}

struct MissionsPageView: View {
    @Environment(\.dismiss) var dismiss
    let userName: String

    @State private var restaurants: [Restaurant] = []
    @State private var restaurantColors: [String: Color] = [:]
    @State private var completedMissionIds: Set<String> = []
    @State private var redeemedMissionIds: Set<String> = []

    let pastelColors: [Color] = [
        Color(red: 1.0, green: 0.87, blue: 0.87),
        Color(red: 0.85, green: 0.93, blue: 1.0),
        Color(red: 0.88, green: 1.0, blue: 0.88),
        Color(red: 1.0, green: 0.95, blue: 0.8),
        Color(red: 0.95, green: 0.85, blue: 1.0),
        Color(red: 0.9, green: 0.95, blue: 1.0)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                HStack {
                    Text("Welcome")
                        .font(.title)
                        .foregroundColor(.gray)
                    + Text(" \(firstNameOnly(from: userName))!")
                        .font(.title)
                        .bold()
                }
                .padding(.top)

                ForEach(restaurants) { restaurant in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(restaurant.name)
                            .font(.title3)
                            .bold()

                        ForEach(restaurant.missions) { mission in
                            let isCompleted = completedMissionIds.contains(mission.id ?? "")
                            let isRedeemed = redeemedMissionIds.contains(mission.id ?? "")

                            let tag = isRedeemed ? "REDEEMED" : (isCompleted ? "COMPLETED" : nil)
                            let dimmed = isRedeemed

                            if isRedeemed {
                                // Show greyed out, no navigation
                                MissionCard(mission: mission, backgroundColor: restaurantColors[restaurant.name] ?? .gray, statusText: tag, isDimmed: dimmed)
                            } else {
                                NavigationLink(destination: MissionDetailView(mission: mission)) {
                                    MissionCard(mission: mission, backgroundColor: restaurantColors[restaurant.name] ?? .gray, statusText: tag, isDimmed: dimmed)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .onAppear {
            fetchMissions()
            fetchCompletedStatuses()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
    
    func firstNameOnly(from fullName: String) -> String {
        return fullName.components(separatedBy: " ").first ?? fullName
    }

    func fetchMissions() {
        let db = Firestore.firestore()
        db.collection("restaurants").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error fetching restaurants: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            var fetchedRestaurants: [Restaurant] = []
            var colorIndex = 0
            let dispatchGroup = DispatchGroup()

            for doc in documents {
                let name = doc.data()["name"] as? String ?? "Unnamed Restaurant"
                let restaurantId = doc.documentID

                if restaurantColors[name] == nil {
                    restaurantColors[name] = pastelColors[colorIndex % pastelColors.count]
                    colorIndex += 1
                }

                dispatchGroup.enter()
                db.collection("restaurants").document(restaurantId).collection("missions").getDocuments { missionSnapshot, error in
                    if let missionDocs = missionSnapshot?.documents {
                        let missions: [Mission] = missionDocs.compactMap { missionDoc in
                            let data = missionDoc.data()
                            return Mission(
                                id: missionDoc.documentID,
                                title: data["title"] as? String ?? "",
                                description: data["description"] as? String ?? "",
                                reward: data["reward"] as? String ?? "",
                                expiration: data["expiration"] as? String,
                                imageUrl: data["imageUrl"] as? String,
                                status: data["status"] as? String ?? "active",
                                steps: (data["steps"] as? [[String: Any]])?.compactMap { stepDict in
                                    guard let description = stepDict["description"] as? String else { return nil }
                                    let link = stepDict["link"] as? String ?? ""
                                    return MissionStep(description: description, link: link)
                                } ?? [],
                                restaurantId: restaurantId
                            )
                        }

                        let restaurant = Restaurant(name: name, missions: missions)
                        fetchedRestaurants.append(restaurant)
                    }
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                self.restaurants = fetchedRestaurants
            }
        }
    }

    func fetchCompletedStatuses() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        db.collection("users").document(userId).collection("completedMissions").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching completed missions: \(error.localizedDescription)")
                return
            }

            var completed: Set<String> = []
            var redeemed: Set<String> = []

            snapshot?.documents.forEach { doc in
                completed.insert(doc.documentID)
                let data = doc.data()
                if let isRedeemed = data["redeemed"] as? Bool, isRedeemed {
                    redeemed.insert(doc.documentID)
                }
            }

            self.completedMissionIds = completed
            self.redeemedMissionIds = redeemed
        }
    }
}
