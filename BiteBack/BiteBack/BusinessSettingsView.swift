//
//  Untitled.swift
//  BiteBack
//
//  Created by Neel Gundavarapu on 3/17/25.
//

import SwiftUI
import FirebaseAuth

struct BusinessSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss // iOS 15+

    @State private var showLogoutConfirmation = false

    var body: some View {
        VStack(spacing: 30) {
            Text("Your Profile")
                .font(.largeTitle)
                .bold()

            Spacer()

            Button(action: {
                showLogoutConfirmation = true
            }) {
                Text("Log Out")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .alert(isPresented: $showLogoutConfirmation) {
                Alert(
                    title: Text("Log Out"),
                    message: Text("Are you sure you want to log out?"),
                    primaryButton: .destructive(Text("Log Out")) {
                        logout()
                    },
                    secondaryButton: .cancel()
                )
            }

            Spacer()
        }
        .padding()
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            dismiss() // Takes user back to login
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

