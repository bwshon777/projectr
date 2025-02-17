//
//  LoginViewController.swift
//  BiteBack
//
//  Created by Brian Shon on 2/2/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }

    private func setupUI() {
        let logoImageView = UIImageView(image: UIImage(systemName: "rectangle.portrait.fill"))
        logoImageView.tintColor = .orange
        logoImageView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.text = "Login"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Please sign in to continue"
        subtitleLabel.textColor = .gray
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)

        let emailTextField = createTextField(placeholder: "Email", keyboardType: .emailAddress)
        let passwordTextField = createTextField(placeholder: "Password", isSecure: true)

        let loginButton = createButton(title: "Log in", backgroundColor: .orange, action: #selector(handleLogin))

        let signUpLabel = UILabel()
        signUpLabel.text = "Don’t have an account?"
        signUpLabel.textColor = .gray

        let signUpButton = UIButton()
        signUpButton.setTitle("Sign up", for: .normal)
        signUpButton.setTitleColor(.orange, for: .normal)
        signUpButton.addTarget(self, action: #selector(goToSignUp), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [logoImageView, titleLabel, subtitleLabel, emailTextField, passwordTextField, loginButton, signUpLabel, signUpButton])
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.alignment = .center
        view.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emailTextField.widthAnchor.constraint(equalToConstant: 300),
            passwordTextField.widthAnchor.constraint(equalToConstant: 300),
            loginButton.widthAnchor.constraint(equalToConstant: 300)
        ])
    }

    @objc private func goToSignUp() {
        let signUpVC = SignUpViewController()
        navigationController?.pushViewController(signUpVC, animated: true)
    }

    @objc private func handleLogin() {
        guard let email = (view.viewWithTag(1) as? UITextField)?.text, !email.isEmpty,
              let password = (view.viewWithTag(2) as? UITextField)?.text, !password.isEmpty else {
            print("Please enter email and password")
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            if let error = error {
                print("Login error: \(error.localizedDescription)")
                return
            }

            // Fetch user data from Firestore
            if let uid = authResult?.user.uid {
                let db = Firestore.firestore()
                db.collection("users").document(uid).getDocument { document, error in
                    if let document = document, document.exists {
                        let userData = document.data()
                        let userMode = userData?["mode"] as? String ?? "personal"

                        // Navigate based on user mode
                        if userMode == "business" {
                            let businessVC = BusinessDashboardViewController()
                            self.navigationController?.pushViewController(businessVC, animated: true)
                        } else {
                            let missionsVC = MissionsPageViewController()
                            self.navigationController?.pushViewController(missionsVC, animated: true)
                        }
                    } else {
                        print("User data not found")
                    }
                }
            }
        }
    }

    private func createTextField(placeholder: String, keyboardType: UIKeyboardType = .default, isSecure: Bool = false) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.keyboardType = keyboardType
        textField.isSecureTextEntry = isSecure
        textField.widthAnchor.constraint(equalToConstant: 300).isActive = true
        textField.tag = isSecure ? 2 : 1 // Tag for email (1) and password (2)
        return textField
    }

    private func createButton(title: String, backgroundColor: UIColor, action: Selector) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.backgroundColor = backgroundColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.widthAnchor.constraint(equalToConstant: 300).isActive = true
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
}