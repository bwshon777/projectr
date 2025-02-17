//
//  BusinessProfileView.swift
//  BiteBack
//
//  Created by Brian Shon on 2/16/25.
//

import SwiftUI

struct BusinessProfileView: View {
    @Environment(\.dismiss) var dismiss

    // Properties to be provided by the calling code (or dummy data for now).
    let businessLogoName: String
    let businessName: String

    var body: some View {
        VStack(spacing: 30) {
            // Centered VStack for logo and business name.
            VStack(spacing: 20) {
                Image(businessLogoName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120) // Adjust logo size here.
                    .clipShape(RoundedRectangle(cornerRadius: 10)) // Adjust corner radius as needed.
                
                Text(businessName)
                    .font(.title)
                    .bold()
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            
            // Buttons: View Missions and Create Missions.
            VStack(spacing: 15) {
                NavigationLink(destination: ViewMissionsView()) {
                    Text("View Missions")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.0, green: 0.698, blue: 1.0))
                        .cornerRadius(8)
                }
                
                NavigationLink(destination: CreateMissionsView()) {
                    Text("Create Missions")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.0, green: 0.698, blue: 1.0))
                        .cornerRadius(8)
                }
            }
            
            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true) // Hide default back button.
        .toolbar {
            // Custom back button with "Profile" title next to it.
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.gray)
                    }
                    Text("Profile")
                        .font(.headline)
                        .foregroundColor(.black)
                }
            }
        }
    }
}

struct BusinessProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BusinessProfileView(businessLogoName: "logoBusiness", businessName: "My Business")
        }
    }
}

// MARK: - Placeholder Views

struct ViewMissionsView: View {
    var body: some View {
        VStack {
            Text("View Missions")
                .font(.title)
                .padding()
            Spacer()
        }
        .navigationTitle("Missions")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CreateMissionsView: View {
    var body: some View {
        VStack {
            Text("Create Missions")
                .font(.title)
                .padding()
            Spacer()
        }
        .navigationTitle("Create Missions")
        .navigationBarTitleDisplayMode(.inline)
    }
}
