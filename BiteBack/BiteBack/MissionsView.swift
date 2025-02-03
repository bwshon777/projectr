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
        VStack(alignment: .leading, spacing: 8) {
            // Mission title
            Text(mission.title)
                .font(.headline)
                .foregroundColor(.white)
            
            // Mission description
            Text(mission.description)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(2)
            
            Spacer()
            
            // Reward tag at the bottom
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
        .padding()
        .frame(width: 250, height: 150)
        .background(
            // A gradient background to make the card pop.
            LinearGradient(
                gradient: Gradient(colors: [Color.orange, Color.red]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(radius: 5)
    }
}

// MARK: - Missions Page View

struct MissionsPageView: View {
    // User's name and the list of restaurants (with their missions) are passed in.
    let userName: String
    let restaurants: [Restaurant]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    
                    // List of restaurants with their missions.
                    ForEach(restaurants) { restaurant in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(restaurant.name)
                                .font(.title2)
                                .bold()
                                .padding(.bottom, 4)
                            
                            // Horizontal scroll for each restaurant's missions.
                            ScrollView(.horizontal, showsIndicators: false) {
                                // Removed the extra horizontal padding from the HStack for alignment.
                                HStack(spacing: 16) {
                                    ForEach(restaurant.missions) { mission in
                                        MissionCard(mission: mission)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer() // Pushes content toward the top
                } // Overall padding, matching your LoginView style.
            }
            .navigationTitle("Missions")

        }
    }
}

// MARK: - Preview

struct MissionsPageView_Previews: PreviewProvider {
    static var previews: some View {
        // Sample mission data for multiple restaurants
        let sampleMissions1 = [
            Mission(title: "Try Our New Dish",
                    description: "Order the new dish to earn a free appetizer.",
                    reward: "Free Appetizer"),
            Mission(title: "Bring a Friend",
                    description: "Bring a friend along and get 20% off your meal.",
                    reward: "20% Off")
        ]
        
        let sampleMissions2 = [
            Mission(title: "Happy Hour",
                    description: "Join our happy hour to enjoy special discounts.",
                    reward: "Discounted Drinks"),
            Mission(title: "Loyalty Challenge",
                    description: "Visit 5 times this month to earn a free meal.",
                    reward: "Free Meal")
        ]
        
        let sampleMissions3 = [
            Mission(title: "Family Fiesta",
                    description: "Bring your family and dine together for a special discount.",
                    reward: "Family Discount"),
            Mission(title: "Weekend Special",
                    description: "Dine during the weekend to earn bonus rewards.",
                    reward: "Bonus Rewards")
        ]
        
        let restaurant1 = Restaurant(name: "Oscars Taco Shop", missions: sampleMissions1)
        let restaurant2 = Restaurant(name: "Bella Italia", missions: sampleMissions2)
        let restaurant3 = Restaurant(name: "Sushi Zen", missions: sampleMissions3)
        
        MissionsPageView(userName: "Brian", restaurants: [restaurant1, restaurant2, restaurant3])
    }
}
