//
//  LoginView.swift
//  BiteBack
//
//  Created by Brian Shon on 2/2/25.
//

import SwiftUI

struct LoginView: View {
    // Bindings for text fields
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    
    var body: some View {
        VStack(spacing: 30) {
            Image("bitebacklogo")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .padding(.top, 80)
                .padding(.bottom, 20)
            
            // Title and subtitle, left-aligned with the input fields
            VStack(alignment: .leading, spacing: 10) {
                Text("Login")
                    .font(.largeTitle)
                    .bold()
                Text("Please sign in to continue")
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Email TextField
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            // Password SecureField
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            // Log In Button
            Button(action: {
                loginUser()
            }) {
                Text("Log In")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 1.0, green: 0.65980, blue: 0))
                    .cornerRadius(8)
            }
            .padding(.top, 10)
            
            // Error message display
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            // Navigation Link to the Sign-Up screen.
            NavigationLink(destination: SignUpView()) {
                Text("Don't have an account? Sign Up")
                    .foregroundColor(.blue)
                    .underline()
                    .padding(.top, 70)
            }
            
            Spacer() // Pushes content to the top
        }
        .padding(30) // Increase overall padding as needed
    }
    
    // Dummy Login Function
    func loginUser() {
        if email.isEmpty || password.isEmpty {
            errorMessage = "Please enter both email and password."
        } else {
            errorMessage = ""
            print("User logged in with email: \(email)")
            // Navigate to the main app screen after a successful login.
        }
    }
}

