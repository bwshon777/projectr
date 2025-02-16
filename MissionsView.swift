//
//  MissionsView.swift
//  BiteBack
//
//  Created by Nicholas Pacella on 2/2/25.
//

// Backend stuff 
// Created by Utsav on 2/16/25

import SwiftUI

import FirebaseCore  // back end imports
import FirebaseFirestore


// MARK: - Data Models

struct Mission: Identifiable {
    let id = String // Firestore-generated ID
    let title: String
    let description: String
    let reward: String
    let imageName: String?  // Optional image name for the mission card
}

struct Restaurant: Identifiable {
    let id = String // Firestore-generated ID
    let name: String
    let missions: [Mission]
}

// MARK: - Mission Card View

struct MissionCard: View {
    let mission: Mission
    
    var body: some View {
        HStack(alignment: .center, spacing: 3) {
            // Left side: Text information
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
        .background(Color(red: 1.0, green: 0.65980, blue: 0))
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}

// MARK: - Missions Page View Model
// Updated for Firestore

class MissionsViewModel: ObservableObject {
    @Published var restaurants: [Restaurant] = []

    init() {
        FirebaseApp.configure() // Initialize Firebase
        fetchRestaurants()
    }

    func fetchRestaurants() {
        let db = Firestore.firestore()
        db.collection("restaurants").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting restaurants: \(error)") // Log the error!
                return
            }

            guard let querySnapshot = querySnapshot else { return }

            self.restaurants = querySnapshot.documents.map { document in
                let restaurantID = document.documentID // Get Firestore ID
                let data = document.data()
                let name = data["name"] as? String ?? ""

                let missionsCollection = document.reference.collection("missions")
                missionsCollection.getDocuments { (missionsSnapshot, missionsError) in
                    if let missionsError = missionsError {
                        print("Error getting missions: \(missionsError)") // Log the error!
                        return
                    }

                    let missions = missionsSnapshot?.documents.map { missionDocument in
                        let missionData = missionDocument.data()
                        return Mission(
                            id: missionDocument.documentID, // Get Firestore ID
                            title: missionData["title"] as? String ?? "",
                            description: missionData["description"] as? String ?? "",
                            reward: missionData["reward"] as? String ?? "",
                            imageURL: missionData["imageURL"] as? String ?? "" // Get image URL
                        )
                    } ?? []

                    DispatchQueue.main.async { // Update on main thread
                        if let index = self.restaurants.firstIndex(where: { $0.id == restaurantID }) {
                            self.restaurants[index].missions = missions
                        }
                    }
                }

                return Restaurant(id: restaurantID, name: name, missions: []) // Initialize with empty missions
            }
        }
    }
}

// MARK: - Missions Page View (Slightly Modified)

struct MissionsPageView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = MissionsViewModel() // Use the view model
    let userName: String

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // 
                // Subheading text.
                Text("Welcome back, \(userName). Let's do some missions!")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                ForEach(viewModel.restaurants) { restaurant in // Iterate through restaurants
                    VStack(alignment: .leading, spacing: 10) {
                        Text(restaurant.name)
                            .font(.title2)
                            .bold()
                            .padding(.bottom, 4)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(restaurant.missions) { mission in // Iterate through missions
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
        // ... (Your navigation code)
         .navigationTitle("Missions")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)  // Hide the default back button.
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


// MARK: - Preview (For now, use sample data to check layout)

struct MissionsPageView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleMissions1 = [
            Mission(id: UUID().uuidString, title: "Try Our Taco", description: "...", reward: "...", imageURL: "taco"),
            Mission(id: UUID().uuidString, title: "Bring a Friend", description: "...", reward: "...", imageURL: "food2")
        ]
        let restaurant1 = Restaurant(id: UUID().uuidString, name: "Oscars Taco Shop", missions: sampleMissions1)

        NavigationStack {
            MissionsPageView(userName: "Brian", restaurants: [restaurant1])
        }
    }
}