//
//  MissionsView.swift
//  BiteBack
//
//  Created by Nicholas Pacella on 2/2/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct Mission: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var reward: String
    var expiration: String?
    var imageUrl: String?
    var status: String
}

struct Restaurant: Identifiable {
    let id = UUID()
    let name: String
    let missions: [Mission]
}

struct MissionCard: View {
    let mission: Mission
    let backgroundColor: Color

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(mission.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)

                Text("\u{1F525} 1 step")
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
    }
}

struct MissionsPageView: View {
    @Environment(\.dismiss) var dismiss
    let userName: String

    @State private var restaurants: [Restaurant] = []
    @State private var restaurantColors: [String: Color] = [:]

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
                    + Text(" \(userName)!")
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
                            MissionCard(
                                mission: mission,
                                backgroundColor: restaurantColors[restaurant.name] ?? Color(.systemGray6)
                            )
                        }
                    }
                }
            }
            .padding()
        }
        .onAppear(perform: fetchMissions)
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
                                status: data["status"] as? String ?? "active"
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
}

struct MissionsPageView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MissionsPageView(userName: "James")
        }
    }
}

