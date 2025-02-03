//
//  LoginView.swift
//  BiteBack
//
//  Created by Brian Shon on 2/2/25.
//

import SwiftUI

struct LoginView: View {
    // Bindings for text fields and password visibility toggle
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var showPassword: Bool = false  // Controls whether password is visible
    
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
            
            // Password Field Container Using ZStack
            ZStack {
                // SecureField for obscured password
                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .opacity(showPassword ? 0 : 1)
                // TextField for visible password
                TextField("Password", text: $password)
                    .textContentType(.password)
                    .opacity(showPassword ? 1 : 0)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            // Overlay the toggle button on the right side.
            .overlay(
                HStack {
                    Spacer()
                    Button(action: {
                        showPassword.toggle()
                    }) {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 10)
                }
            )
            
            // NavigationLink for "Forgot Password"
            NavigationLink(destination: ForgotPasswordView()) {
                Text("Forgot Password?")
                    .font(.subheadline)
                    .foregroundColor(Color(red: 1.0, green: 0.65980, blue: 0))
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top, -20)
            
            
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
            
            // Error Message Area with Fixed Height to Reserve Space
            Group {
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                } else {
                    Text(" ")
                }
            }
            .frame(height: 20)
            
            // Navigation Link to the Sign-Up screen.
            NavigationLink(destination: SignUpView()) {
                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .foregroundColor(.gray)
                    Text("Sign up")
                        .foregroundColor(Color(red: 1.0, green: 0.65980, blue: 0))
                }
                .padding(.top, 10)
                .contentShape(Rectangle())
            }
            
            Spacer() // Pushes content to the top
        }
        .padding(30)
    }
    
    // MARK: - Login Validation Function
    func loginUser() {
        // Validate non-empty fields.
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.isEmpty else {
            errorMessage = "Please enter both email and password."
            return
        }
        
        // Validate email format.
        guard email.isValidEmail else {
            errorMessage = "Please enter a valid email address."
            return
        }
        
        // Validate password length (e.g., minimum 6 characters).
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return
        }
        
        // If all validation passes, clear the error and continue.
        errorMessage = ""
        print("User logged in with email: \(email)")
        // Continue with your authentication logic…
    }
}

// MARK: - Preview Provider
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LoginView()
        }
    }
}
