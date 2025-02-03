//
//  SignUpView.swift
//  BiteBack
//
//  Created by Brian Shon on 2/2/25.
//

import SwiftUI

enum SignUpMode: String, CaseIterable, Identifiable {
    case personal = "Personal"
    case business = "Business"
    var id: String { self.rawValue }
}

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss

    @State private var selectedMode: SignUpMode = .personal

    // Personal sign-up fields.
    @State private var personalName: String = ""
    @State private var personalEmail: String = ""
    @State private var personalPhone: String = ""
    @State private var personalPassword: String = ""

    // Business sign-up fields.
    @State private var businessName: String = ""
    @State private var businessEmail: String = ""
    @State private var businessPhone: String = ""
    @State private var businessPassword: String = ""
    @State private var verifyBusiness: Bool = false

    // Common state for both forms.
    @State private var acceptedTerms: Bool = false
    @State private var errorMessage: String = ""
    
    // Navigation state variable.
    @State private var navigateToMissions: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerView
                formFields
                if selectedMode == .business {
                    businessVerificationToggle
                }
                termsAndConditionsToggle
                signUpButton
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                // Hidden NavigationLink that navigates to MissionsPageView when activated.
                NavigationLink(
                    destination: MissionsPageView(userName: personalName.isEmpty ? "User" : personalName, restaurants: sampleRestaurants),
                    isActive: $navigateToMissions
                ) {
                    EmptyView()
                }
            }
            .padding(30)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    // MARK: - Header View
    var headerView: some View {
        VStack(spacing: 30) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Sign Up")
                    .font(.title2)
                    .bold()
                Text("Let's create your account.")
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Spacer()
                Picker("", selection: $selectedMode) {
                    ForEach(SignUpMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 200)
                .padding(.bottom, 10)
                Spacer()
            }
        }
    }
    
    // MARK: - Form Fields
    var formFields: some View {
        VStack(spacing: 15) {
            if selectedMode == .personal {
                TextField("Name", text: $personalName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                TextField("Email", text: $personalEmail)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                TextField("Phone", text: $personalPhone)
                    .keyboardType(.phonePad)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                SecureField("Password", text: $personalPassword)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            } else {
                TextField("Business Name", text: $businessName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                TextField("Email", text: $businessEmail)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                TextField("Phone", text: $businessPhone)
                    .keyboardType(.phonePad)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                SecureField("Password", text: $businessPassword)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
        }
    }
    
    // MARK: - Business Verification Toggle (only in Business mode)
    var businessVerificationToggle: some View {
        Toggle("I will verify my business upon signup", isOn: $verifyBusiness)
            .toggleStyle(CustomCheckboxToggleStyle())
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 4)
    }
    
    // MARK: - Terms and Conditions Toggle
    var termsAndConditionsToggle: some View {
        Toggle(isOn: $acceptedTerms) {
            HStack(spacing: 0) {
                Text("I accept the ")
                NavigationLink(destination: TermsAndConditionsView(accepted: $acceptedTerms)) {
                    Text("Terms and Conditions")
                        .underline()
                        .foregroundColor(Color(red: 1.0, green: 0.65980, blue: 0))
                }
            }
        }
        .toggleStyle(CustomCheckboxToggleStyle())
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 4)
    }
    
    // MARK: - Sign Up Button
    var signUpButton: some View {
        Button(action: { signUpUser() }) {
            Text("Sign Up")
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 1.0, green: 0.65980, blue: 0))
                .cornerRadius(8)
        }
        .padding(.top, 10)
    }
    
    // MARK: - Sign-Up Validation Function
    func signUpUser() {
        guard acceptedTerms else {
            errorMessage = "Please accept the Terms and Conditions."
            return
        }
        errorMessage = ""
        
        if selectedMode == .personal {
            guard !personalName.trimmingCharacters(in: .whitespaces).isEmpty,
                  !personalEmail.trimmingCharacters(in: .whitespaces).isEmpty,
                  !personalPhone.trimmingCharacters(in: .whitespaces).isEmpty,
                  !personalPassword.isEmpty else {
                errorMessage = "Please fill in all fields."
                return
            }
            guard personalEmail.isValidEmail else {
                errorMessage = "Please enter a valid email address."
                return
            }
            guard personalPhone.allSatisfy({ $0.isNumber }) else {
                errorMessage = "Phone number should contain only digits."
                return
            }
            guard personalPassword.count >= 6 else {
                errorMessage = "Password must be at least 6 characters."
                return
            }
            print("Personal user signed up: \(personalName), email: \(personalEmail)")
            navigateToMissions = true
        } else {
            guard !businessName.trimmingCharacters(in: .whitespaces).isEmpty,
                  !businessEmail.trimmingCharacters(in: .whitespaces).isEmpty,
                  !businessPhone.trimmingCharacters(in: .whitespaces).isEmpty,
                  !businessPassword.isEmpty else {
                errorMessage = "Please fill in all fields."
                return
            }
            guard businessEmail.isValidEmail else {
                errorMessage = "Please enter a valid email address."
                return
            }
            guard businessPhone.allSatisfy({ $0.isNumber }) else {
                errorMessage = "Phone number should contain only digits."
                return
            }
            guard businessPassword.count >= 6 else {
                errorMessage = "Password must be at least 6 characters."
                return
            }
            print("Business user signed up: \(businessName), email: \(businessEmail), verify: \(verifyBusiness)")
            navigateToMissions = true
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

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SignUpView()
        }
    }
}
