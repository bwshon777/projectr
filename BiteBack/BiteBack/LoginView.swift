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
    @State private var navigateToMissions: Bool = false // trigger here
    @State private var navigateToBusinessProfile: Bool = false
    
    // Focus state for text fields (for keyboard stuff)
    @FocusState private var focusedField: LoginField?
    
    var body: some View {
        VStack(spacing: 30) {
            Image("bitebacklogo")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .padding(.top, 80)
                .padding(.bottom, 20)
            
            // Title and subtitle
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
            
            // "Forgot Password" NavigationLink
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
            
            // Error Message Area (fixed height)
            Group {
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                } else {
                    Text(" ")
                }
            }
            .frame(height: 20)
            
            // NavigationLink to Sign-Up screen.
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
            
            // Hidden NavigationLink, triggers navigation to MissionsPageView.
            NavigationLink(
                destination: MissionsPageView(userName: "Test User", restaurants: sampleRestaurants),
                isActive: $navigateToMissions
            ) {
                EmptyView()
            }
            
            NavigationLink(
                destination: BusinessProfileView(businessLogoName: "image", businessName: "Oscars"),
                isActive: $navigateToBusinessProfile
            ) {
                EmptyView()
            }
        }
        .padding(30)
        // Dismiss keyboard when tapping anywhere outside.
        .onTapGesture { focusedField = nil }
    }
    
    // MARK: - Login Validation Function
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
            
            // Successful login. Now fetch additional user data to determine account type.
            let db = Firestore.firestore()
            if let uid = authResult?.user.uid {
                db.collection("users").document(uid).getDocument { document, error in
                    if let document = document, document.exists, let data = document.data(),
                       let mode = data["mode"] as? String {
                        errorMessage = ""
                        print("User logged in with email: \(email), mode: \(mode)")
                        if mode == "business" {
                            // Navigate to BusinessProfileView.
                            navigateToBusinessProfile = true
                        } else {
                            // Navigate to MissionsPageView.
                            navigateToMissions = true
                        }
                    } else {
                        errorMessage = "Failed to fetch user data."
                    }
                }
            }
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
