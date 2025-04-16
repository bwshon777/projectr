//
//  LoginView.swift
//  BiteBack
//
//  Created by Brian Shon on 2/2/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// Enum to track which text field is focused.
enum LoginField: Hashable {
    case email, password
}

struct LoginView: View {
    // MARK: - State Properties
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var showPassword: Bool = false
    @State private var navigateToMissions: Bool = false
    @State private var navigateToBusinessProfile: Bool = false
    @State private var userDisplayName: String = "" // 👈 NEW
    @State private var businessDisplayName: String = ""

    @FocusState private var focusedField: LoginField?

    var body: some View {
        VStack(spacing: 30) {
            Image("bitebacklogo")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .padding(.top, 100)
                .padding(.bottom, 20)
            
            Text("BiteBack")
                .font(.system(size: 40))
                .bold()
                .padding(.top, -40)

            // Title and subtitle
            VStack(alignment: .leading, spacing: 10) {
                Text("Login")
                    .font(.system(size: 25))
                    .bold()
                Text("Please sign in to continue")
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, -10)

            // Email TextField
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .focused($focusedField, equals: .email)

            // Password Field Container
            ZStack {
                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .opacity(showPassword ? 0 : 1)
                    .focused($focusedField, equals: .password)
                TextField("Password", text: $password)
                    .textContentType(.password)
                    .opacity(showPassword ? 1 : 0)
                    .focused($focusedField, equals: .password)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .overlay(
                HStack {
                    Spacer()
                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 10)
                }
            )

            // "Forgot Password"
            NavigationLink(destination: ForgotPasswordView()) {
                Text("Forgot Password?")
                    .font(.subheadline)
                    .foregroundColor(Color(red: 0.0, green: 0.698, blue: 1.0))
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top, -20)

            // Log In Button
            Button(action: { loginUser() }) {
                Text("Log In")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 0.0, green: 0.698, blue: 1.0))
                    .cornerRadius(8)
            }
            .padding(.top, 10)

            // Error Message
            Group {
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                } else {
                    Text(" ")
                }
            }
            .frame(height: 20)

            // Sign-Up Link
            NavigationLink(destination: SignUpView()) {
                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .foregroundColor(.gray)
                    Text("Sign up")
                        .foregroundColor(Color(red: 0.0, green: 0.698, blue: 1.0))
                }
                .padding(.top, 10)
                .contentShape(Rectangle())
            }

            Spacer()

            // Navigation Links
            NavigationLink(
                destination: CustomerTabView(userName: userDisplayName),
                isActive: $navigateToMissions
            ) {
                EmptyView()
            }

            NavigationLink(
                destination: BusinessTabView(businessName: businessDisplayName),
                isActive: $navigateToBusinessProfile
            ) {
                EmptyView()
            }
        }
        .padding(30)
        .onTapGesture { focusedField = nil }
    }

    // MARK: - Login Function
    func loginUser() {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.isEmpty else {
            errorMessage = "Please enter both email and password."
            return
        }
        guard email.isValidEmail else {
            errorMessage = "Please enter a valid email address."
            return
        }
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }

            let db = Firestore.firestore()
            if let uid = authResult?.user.uid {
                db.collection("users").document(uid).getDocument { document, error in
                    if let document = document, document.exists, let data = document.data(),
                       let mode = data["mode"] as? String {

                        errorMessage = ""
                        userDisplayName = data["name"] as? String ?? "User" // 👈 Extract name
                        
                        businessDisplayName = data["businessName"] as? String ?? "User"

                        print("Logged in as \(userDisplayName) (\(email)) in \(mode) mode")

                        if mode == "business" {
                            navigateToBusinessProfile = true
                        } else {
                            navigateToMissions = true
                        }
                    } else {
                        errorMessage = "Failed to fetch user data."
                    }
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LoginView()
        }
    }
}
