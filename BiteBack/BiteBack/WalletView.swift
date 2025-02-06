//
//  WalletView.swift
//  BiteBack
//
//  Created by [Your Name] on [Date].
//

import SwiftUI

/// Data model representing a virtual punch card.
struct PunchCardData: Identifiable {
    let id = UUID()
    let restaurantName: String
    let restaurantLogoName: String
    let restaurantPhotoName: String
    let barcode: String
    let rewardDescription: String
    let totalPunchSpots: Int
    let completedPunches: Int
    let backgroundColor: Color
    let textColor: Color
    let highlightColor: Color
}

/// A view that displays virtual punch cards in a wallet style similar to Apple Wallet.
struct WalletView: View {
    @State private var searchText: String = ""
    @State private var selectedCard: PunchCardData? = nil
    
    // Dummy data for demonstration.
    let cards: [PunchCardData] = [
        PunchCardData(
            restaurantName: "Nicoletto's",
            restaurantLogoName: "nicolettos",
            restaurantPhotoName: "pastapic",
            barcode: "barcode",
            rewardDescription: "5 PUNCHES FOR A FREE PIZZA",
            totalPunchSpots: 8,
            completedPunches: 3,
            backgroundColor: Color(red: 0.9176, green: 0.9137, blue: 0.8863),
            textColor: .black,
            highlightColor: .brown
        ),
        PunchCardData(
            restaurantName: "Oscars Taco Shop",
            restaurantLogoName: "oscarslogo",
            restaurantPhotoName: "tacopic",
            barcode: "barcode",
            rewardDescription: "10 PUNCHES FOR A FREE TACO",
            totalPunchSpots: 10,
            completedPunches: 6,
            backgroundColor: Color(red: 1.0, green: 0.8824, blue: 0.3608),
            textColor: .black,
            highlightColor: .red
        ),
        PunchCardData(
            restaurantName: "I Love Sushi",
            restaurantLogoName: "ilsushilogo",
            restaurantPhotoName: "sushipic",
            barcode: "barcode",
            rewardDescription: "7 PUNCHES FOR A FREE ROLL",
            totalPunchSpots: 7,
            completedPunches: 7,
            backgroundColor: Color.red,
            textColor: .white,
            highlightColor: .red
        ),
        PunchCardData(
            restaurantName: "Pasta Paradise",
            restaurantLogoName: "logoPasta",
            restaurantPhotoName: "photoPasta",
            barcode: "barcode",
            rewardDescription: "5 PUNCHES FOR A FREE BOWL OF PASTA",
            totalPunchSpots: 5,
            completedPunches: 2,
            backgroundColor: Color(red: 0.95, green: 0.95, blue: 0.9),
            textColor: .black,
            highlightColor: .orange
        ),
        PunchCardData(
            restaurantName: "Burger Barn",
            restaurantLogoName: "logoBurger",
            restaurantPhotoName: "photoBurger",
            barcode: "barcodeBurger",
            rewardDescription: "8 PUNCHES FOR A FREE BURGER",
            totalPunchSpots: 8,
            completedPunches: 4,
            backgroundColor: Color(red: 0.92, green: 0.92, blue: 0.92),
            textColor: .black,
            highlightColor: .purple
        )
    ]
    
    // Filter cards based on the search text.
    var filteredCards: [PunchCardData] {
        if searchText.isEmpty {
            return cards
        } else {
            return cards.filter { $0.restaurantName.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Main content: wallet view with search and stacked cards.
                VStack {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(filteredCards) { card in
                                VirtualPunchCardView(
                                    restaurantLogoName: card.restaurantLogoName,
                                    restaurantPhotoName: card.restaurantPhotoName,
                                    barcode: card.barcode,
                                    rewardDescription: card.rewardDescription,
                                    totalPunchSpots: card.totalPunchSpots,
                                    completedPunches: card.completedPunches,
                                    backgroundColor: card.backgroundColor,
                                    textColor: card.textColor,
                                    highlightColor: card.highlightColor
                                )
                                // When a card is tapped, select it.
                                .onTapGesture {
                                    withAnimation {
                                        selectedCard = card
                                    }
                                }
                            }
                        }
                        .padding(.top, 10)
                    }
                    .searchable(text: $searchText, prompt: "Search Restaurants")
                    .navigationTitle("Wallet")
                }
                // Apply a blur to the main content when a card is selected.
                .blur(radius: selectedCard != nil ? 10 : 0)
                
                // If a card is selected, overlay with a dimmed, blurred background and show the card.
                if let selected = selectedCard {
                    // Dim the background.
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                selectedCard = nil
                            }
                        }
                    
                    // Show the selected card pulled out from the stack.
                    VirtualPunchCardView(
                        restaurantLogoName: selected.restaurantLogoName,
                        restaurantPhotoName: selected.restaurantPhotoName,
                        barcode: selected.barcode,
                        rewardDescription: selected.rewardDescription,
                        totalPunchSpots: selected.totalPunchSpots,
                        completedPunches: selected.completedPunches,
                        backgroundColor: selected.backgroundColor,
                        textColor: selected.textColor,
                        highlightColor: selected.highlightColor
                    )
                    .frame(width: 350, height: 220)
                    .transition(.scale)
                    .onTapGesture {
                        withAnimation {
                            selectedCard = nil
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        WalletView()
    }
}

