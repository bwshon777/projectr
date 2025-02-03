//
//  SignUpView.swift
//  BiteBack
//
//  Created by Brian Shon on 2/2/25.
//

import SwiftUI

struct SignUpView: View {
    // Bindings for the sign-up text fields.
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 10) {
                Text("Sign Up")
                    .font(.title2)
                    .bold()
                    .padding(.top, 30)
                
                Text("Let's create your account.")
                    .foregroundColor(.gray)
            }
            
            // Name TextField
            TextField("Name", text: $name)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            // Email TextField
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            // Phone TextField
            TextField("Phone", text: $phone)
                .keyboardType(.phonePad)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            // Password SecureField
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            // Sign Up Button
            Button(action: {
                signUpUser()
            }) {
                Text("Sign Up")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 1.0, green: 0.65980, blue: 0))
                    .cornerRadius(8)
            }
            .padding(.top, 10)
            
            // Display error message if needed.
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            Spacer() // Pushes content to the top
        }
        .padding() // Overall padding for the view
        .navigationTitle("Sign Up") // Sets the navigation title
    }
    
    // Dummy Sign-Up Function
    // MARK: - Sign-Up Validation Function
    func signUpUser() {
        // Validate non-empty fields.
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !phone.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }
        
        // Validate email format.
        guard email.isValidEmail else {
            errorMessage = "Please enter a valid email address."
            return
        }
        
        // Validate that the phone number contains only digits.
        guard phone.allSatisfy({ $0.isNumber }) else {
            errorMessage = "Phone number should contain only digits."
            return
        }
        
        // Validate password length (e.g., minimum 6 characters).
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return
        }
        
        // If all validation passes, clear the error and continue.
        errorMessage = ""
        print("User signed up: \(name), email: \(email)")
        // Continue with your sign-up logic…
    }
}

