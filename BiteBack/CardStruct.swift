//
//  VirtualPunchCardView.swift
//  BiteBack
//
//  Created by Brian Shon on 2/6/25.
//

import SwiftUI

/// A SwiftUI view representing a virtual punch card for a restaurant.
/// This card is designed to mimic the size and shape of a credit card.
struct VirtualPunchCardView: View {
    // MARK: - Properties
    /// The asset name for the restaurant's logo (displayed in the top left).
    let restaurantLogoName: String
    /// The asset name for the restaurant's photo (displayed in the top right).
    let restaurantPhotoName: String
    /// The asset name for the barcode image.
    let barcode: String
    /// A short, one-line description of the reward.
    let rewardDescription: String
    /// The total number of punch spots on the card.
    let totalPunchSpots: Int
    /// The number of completed punches.
    let completedPunches: Int
    // background color for card
    let backgroundColor: Color
    // secondary color for text
    let textColor: Color
    // tertiary color for fills and highlights
    let highlightColor: Color

    // MARK: - Body
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            // Top Row: Restaurant Logo and Photo
            HStack {
                // Restaurant photo (top left)
                Image(restaurantPhotoName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60) // Adjust logo size here.
                    .padding(.top, 15)
                
                Spacer()
                
                // Restaurant logo (top right) in a rounded square.
                Image(restaurantLogoName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 60) // Adjust photo size here.
                    .clipShape(RoundedRectangle(cornerRadius: 8)) // Adjust corner radius here.
                    .padding(.top, 15)
            }
            
            // Middle: Barcode Image
            HStack {
                Spacer()
                Image(barcode)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 320, height: 40) // Barcode width set to 320.
                    .cornerRadius(5) // Modify corner radius if desired.
                Spacer()
            }
            
            // Reward Description (one line)
            Text(rewardDescription)
                .font(.callout) // Modify reward font here.
                .lineLimit(1)
                .bold()
                .foregroundColor(textColor)
            
            // Bottom Row: Punch Spots (chain width = 290, with 15px margins on each end)
            // Calculate dynamic spacing:
            // Total available chain width = 320 - 15 - 15 = 290.
            // Each circle is 30px wide.
            // Spacing = (290 - (totalPunchSpots * 30)) / (totalPunchSpots - 1) [if more than one spot]
            let chainWidth: CGFloat = 320
            let circleWidth: CGFloat = 30
            let spacing: CGFloat = totalPunchSpots > 1 ? (chainWidth - (CGFloat(totalPunchSpots) * circleWidth)) / CGFloat(totalPunchSpots - 1) : 0
            
            HStack {
                Spacer().frame(width: 15)
                HStack(spacing: spacing) {
                    ForEach(0..<totalPunchSpots, id: \.self) { index in
                        Circle()
                            .strokeBorder(Color.black, lineWidth: 1) // Modify circle border here.
                            .background(
                                Circle().foregroundColor(index < completedPunches ? highlightColor : Color.white)
                            )
                            .frame(width: circleWidth, height: circleWidth)
                    }
                }
                .frame(width: chainWidth)
                Spacer().frame(width: 15)
            }
            Spacer() // Optionally push content to the top.
        }
        .padding()
        // Set a fixed frame to mimic a credit card's dimensions. Adjust as needed.
        .frame(width: 350, height: 220)
        .background(backgroundColor) // Modify card background color if desired.
        .cornerRadius(15) // Adjust card corner radius.
//        .shadow(radius: 10) // Adjust shadow as needed.
        // Overlay a black border around the card.
//        .overlay(
//            RoundedRectangle(cornerRadius: 15)
//                .stroke(Color.black, lineWidth: 2)
//        )
    }
}

// MARK: - Preview
struct VirtualPunchCardView_Previews: PreviewProvider {
    static var previews: some View {
        VirtualPunchCardView(
            restaurantLogoName: "nicolettos",
            restaurantPhotoName: "pastapic",
            barcode: "barcode",
            rewardDescription: "5 PUNCHES FOR A FREE BOWL OF PASTA",
            totalPunchSpots: 7,
            completedPunches: 5,
            backgroundColor: Color(red: 0.9176, green: 0.9137, blue: 0.8863),
            textColor: Color.black,
            highlightColor: Color.brown
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
