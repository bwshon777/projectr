//
//  MissionsView.swift
//  BiteBack
//
//  Created by Nicholas Pacella on 2/2/25.
//

import SwiftUI

// MARK: - Data Models

struct Mission: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let reward: String
    let imageName: String?  // Optional image name for the mission card
}

struct Restaurant: Identifiable {
    let id = UUID()
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

// MARK: - Missions Page View

struct MissionsPageView: View {
    // Use the dismiss environment value to pop this view.
    @Environment(\.dismiss) var dismiss

    // User's name and the list of restaurants (with their missions) are passed in.
    let userName: String
    let restaurants: [Restaurant]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                
                // Subheading text.
                Text("Welcome back, \(userName). Let's do some missions!")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                // List of restaurants with their missions.
                ForEach(restaurants) { restaurant in
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
                
                Spacer() // Pushes content toward the top.
            }
        }
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

// MARK: - Preview

struct MissionsPageView_Previews: PreviewProvider {
    static var previews: some View {
        // Sample mission data for multiple restaurants.
        let sampleMissions1 = [
            Mission(title: "Try Our Taco",
                    description: "Order our famous taco dish to earn a free appetizer.",
                    reward: "Free Appetizer",
                    imageName: "taco"),
            Mission(title: "Bring a Friend",
                    description: "Bring a friend along and get 20% off your meal.",
                    reward: "20% Off",
                    imageName: "food2")
        ]
        
        let sampleMissions2 = [
            Mission(title: "Happy Hour",
                    description: "Join our happy hour to enjoy special discounts.",
                    reward: "Discounted Drinks",
                    imageName: "cocktail"),
            Mission(title: "Loyalty Challenge",
                    description: "Visit 5 times this month to earn a free meal.",
                    reward: "Free Meal",
                    imageName: "food4")
        ]
        
        let sampleMissions3 = [
            Mission(title: "Family Fiesta",
                    description: "Bring your family and dine together for a special discount.",
                    reward: "Family Discount",
                    imageName: "sushi"),
            Mission(title: "Weekend Special",
                    description: "Dine during the weekend to earn bonus rewards.",
                    reward: "Bonus Rewards",
                    imageName: "food6")
        ]
        
        let restaurant1 = Restaurant(name: "Oscars Taco Shop", missions: sampleMissions1)
        let restaurant2 = Restaurant(name: "Bella Italia", missions: sampleMissions2)
        let restaurant3 = Restaurant(name: "Sushi Zen", missions: sampleMissions3)
        
        NavigationStack {
            MissionsPageView(userName: "Brian", restaurants: [restaurant1, restaurant2, restaurant3])
        }
    }
}

