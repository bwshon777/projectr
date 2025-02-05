//
//  ForgotPasswordView.swift
//  BiteBack
//
//  Created by Brian Shon on 2/2/25.
//

import SwiftUI

// Define an enum for the ForgotPassword text field.
enum ForgotPasswordField: Hashable {
    case email
}

struct ForgotPasswordView: View {
    @Environment(\.dismiss) var dismiss  // Allows dismissing the view

    @State private var email: String = ""
    @State private var errorMessage: String = ""
    @State private var showAlert: Bool = false

    // Focus state for the email text field.
    @FocusState private var focusedField: ForgotPasswordField?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Forgot your password?")
                .font(.title2)
                .bold()
                .padding(.top, 40)
            
            Text("Enter the email address for your account, and we'll send you password reset instructions.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundColor(.gray)
            
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 30)
                .focused($focusedField, equals: .email)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.horizontal, 30)
            }
            
            Button(action: {
                resetPassword()
            }) {
                Text("Reset Password")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 0.0, green: 0.698, blue: 1.0))
                    .cornerRadius(8)
            }
            .padding(.horizontal, 30)
            .padding(.top, 10)
            
            Spacer()
        }
        .onTapGesture {
            focusedField = nil
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Password Reset", isPresented: $showAlert, actions: {
            Button("OK") {
                dismiss()  // Dismiss the view when the alert is acknowledged.
            }
        }, message: {
            Text("A password reset email has been sent to \(email).")
        })
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
        print("Password reset email sent to \(trimmedEmail)")
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
