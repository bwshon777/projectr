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
    
    // Navigation state variable for Missions page.
    @State private var navigateToMissions: Bool = false
    
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
                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .opacity(showPassword ? 0 : 1)
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
            
            // Error Message Area with Fixed Height
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
            
            Spacer()
            
            // Hidden NavigationLink that triggers navigation to MissionsPageView.
            NavigationLink(
                destination: MissionsPageView(userName: "Test User", restaurants: sampleRestaurants),
                isActive: $navigateToMissions
            ) {
                EmptyView()
            }
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
        // Validate password length.
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return
        }
        
        // Check for the specific test credentials.
        if email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "test@test.com" && password == "test1234" {
            errorMessage = ""
            print("User logged in with email: \(email)")
            navigateToMissions = true
        } else {
            errorMessage = "Invalid credentials."
        }
    }
    
    // MARK: - Sample Data for MissionsPageView
    var sampleRestaurants: [Restaurant] {
        let sampleMissions1 = [
            Mission(title: "Try Our Taco",
                    description: "Order our famous taco dish to earn a free appetizer.",
                    reward: "Free Appetizer",
                    imageName: "taco"),
            Mission(title: "Bring a Friend",
                    description: "Bring a friend along and get 20% off your meal.",
                    reward: "20% Off",
                    imageName: "food2")
        ]
        let sampleMissions2 = [
            Mission(title: "Happy Hour",
                    description: "Join our happy hour to enjoy special discounts.",
                    reward: "Discounted Drinks",
                    imageName: "cocktail"),
            Mission(title: "Loyalty Challenge",
                    description: "Visit 5 times this month to earn a free meal.",
                    reward: "Free Meal",
                    imageName: "food4")
        ]
        let sampleMissions3 = [
            Mission(title: "Family Fiesta",
                    description: "Bring your family and dine together for a special discount.",
                    reward: "Family Discount",
                    imageName: "sushi"),
            Mission(title: "Weekend Special",
                    description: "Dine during the weekend to earn bonus rewards.",
                    reward: "Bonus Rewards",
                    imageName: "food6")
        ]
        
        let restaurant1 = Restaurant(name: "Oscars Taco Shop", missions: sampleMissions1)
        let restaurant2 = Restaurant(name: "Bella Italia", missions: sampleMissions2)
        let restaurant3 = Restaurant(name: "Sushi Zen", missions: sampleMissions3)
        
        return [restaurant1, restaurant2, restaurant3]
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LoginView()
        }
    }
}
