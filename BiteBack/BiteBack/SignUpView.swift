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
        VStack(spacing: 20) {
            // Logo Placeholder for Sign-Up
            Image("yourSignUpLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding(.bottom, 20)
            
            Text("Sign Up")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 10)
            
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
                    .background(Color.green)
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
    func signUpUser() {
        if name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty {
            errorMessage = "Please fill in all fields."
        } else {
            errorMessage = ""
            print("User signed up: \(name), email: \(email)")
            // After a successful sign-up, navigate as needed.
        }
    }
}

