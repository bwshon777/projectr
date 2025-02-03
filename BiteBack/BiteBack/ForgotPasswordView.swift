//
//  ForgotPasswordView.swift
//  BiteBack
//
//  Created by Brian Shon on 2/2/25.
//

import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) var dismiss  // Allows us to pop the view when finished

    @State private var email: String = ""
    @State private var errorMessage: String = ""
    @State private var showAlert: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Forgot your password?")
                .font(.title2)
                .bold()
                .padding(.top, 40)
            
            Text("Enter the email address for your account, and we'll send you a password reset instructions.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundColor(.gray)
            
            // Email TextField
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 30)
            
            // Error Message (if any)
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.horizontal, 30)
            }
            
            // Reset Password Button
            Button(action: {
                resetPassword()
            }) {
                Text("Reset Password")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 1.0, green: 0.65980, blue: 0))
                    .cornerRadius(8)
            }
            .padding(.horizontal, 30)
            .padding(.top, 10)
            
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        // When showAlert is true, display an alert with a confirmation message.
        .alert("Password Reset", isPresented: $showAlert, actions: {
            Button("OK") {
                dismiss()  // Dismisses the Forgot Password view, returning to the login page.
            }
        }, message: {
            Text("A password reset email has been sent to \(email).")
        })
        .navigationBarBackButtonHidden(true) // Hide the default back button
        .toolbar {
            // Custom back button in the navigation bar leading position.
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss() // Dismiss the view
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.gray) // Adjust color as desired
                }
            }
        }
    }
    
    // Validate the email and simulate sending a reset email.
    func resetPassword() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        guard !trimmedEmail.isEmpty else {
            errorMessage = "Please enter your email address."
            return
        }
        
        guard trimmedEmail.isValidEmail else {
            errorMessage = "Please enter a valid email address."
            return
        }
        
        errorMessage = ""
        // Simulate sending the reset email (replace with your own logic as needed).
        print("Password reset email sent to \(trimmedEmail)")
        
        // Show confirmation alert.
        showAlert = true
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ForgotPasswordView()
        }
    }
}
