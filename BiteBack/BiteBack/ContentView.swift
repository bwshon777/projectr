//
//  ContentView.swift
//  BiteBack
//
//  Created by Brian Shon on 2/2/25.
//

import SwiftUI

// The main content view that starts with the Login screen.
struct ContentView: View {
    var body: some View {
        NavigationStack {
            LoginView()
        }
    }
}

// MARK: - Login View
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
                .padding(.bottom, 20)
                .padding(.top, 60)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Login")
                    .font(.largeTitle)
                    .bold()
                    .frame(alignment: .leading)
                
                Text("Please sign in to continue")
                    .foregroundColor(.gray)
            }
            
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
            
            // error message if fields are empty
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            // Navigation Link to the Sign-Up screen.
            NavigationLink(destination: SignUpView()) {
                Text("Don't have an account? Sign Up")
                    .foregroundColor(.blue)
                    .underline()
                    .padding(.top, 120) // Adjust spacing above the link here
            }
            
            Spacer() // Pushes content to the top; adjust as needed.
        }
        .padding() // Overall padding for the view; adjust as desired.
    }
    
    // MARK: - Dummy Login Function
    func loginUser() {
        // Replace this dummy logic with your actual authentication logic.
        if email.isEmpty || password.isEmpty {
            errorMessage = "Please enter both email and password."
        } else {
            errorMessage = ""
            print("User logged in with email: \(email)")
            // Navigate to the main app screen after a successful login.
        }
    }
}

// MARK: - Sign Up View
struct SignUpView: View {
    // Bindings for the sign-up text fields.
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    
    var body: some View {
        VStack(spacing: 20) { // Adjust spacing between elements here
            // MARK: Logo Placeholder for Sign-Up
            // Replace "yourSignUpLogo" with your asset name or a different logo image.
            Image("yourSignUpLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100) // Customize logo size here
                .padding(.bottom, 20) // Adjust spacing below the logo
            
            Text("Sign Up")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 10) // Adjust title spacing
            
            // Name TextField
            TextField("Name", text: $name)
                .padding()
                .background(Color(.systemGray6)) // Change background color if desired
                .cornerRadius(8)
            
            // Email TextField
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .padding()
                .background(Color(.systemGray6)) // Change background color if desired
                .cornerRadius(8)
            
            // Phone TextField
            TextField("Phone", text: $phone)
                .keyboardType(.phonePad)
                .padding()
                .background(Color(.systemGray6)) // Change background color if desired
                .cornerRadius(8)
            
            // Password SecureField
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.systemGray6)) // Change background color if desired
                .cornerRadius(8)
            
            // Sign Up Button
            Button(action: {
                signUpUser()
            }) {
                Text("Sign Up")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green) // Change button color here
                    .cornerRadius(8)
            }
            .padding(.top, 10)
            
            // Display an error message if needed.
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            Spacer() // Pushes content to the top; adjust as needed.
        }
        .padding() // Overall padding for the view; adjust as desired.
        .navigationTitle("Sign Up") // Optional: sets the navigation title.
    }
    
    // MARK: - Dummy Sign-Up Function
    func signUpUser() {
        // Replace this dummy logic with your actual sign-up process.
        if name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty {
            errorMessage = "Please fill in all fields."
        } else {
            errorMessage = ""
            print("User signed up: \(name), email: \(email)")
            // After a successful sign-up, you might navigate to the main app screen or back to the login screen.
        }
    }
}

// MARK: - Preview Provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

