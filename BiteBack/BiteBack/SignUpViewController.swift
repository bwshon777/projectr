//
//  SignUpViewController.swift
//  BiteBack
//
//  Created by Brian Shon on 2/2/25.
//

import UIKit

class SignUpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }

    private func setupUI() {
        let backButton = UIButton()
        backButton.setTitle("< Back", for: .normal)
        backButton.setTitleColor(.black, for: .normal)
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)

        let titleLabel = UILabel()
        titleLabel.text = "Sign up"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Let's create your account"
        subtitleLabel.textColor = .gray
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)

        let nameTextField = createTextField(placeholder: "Account Owner")
        let emailTextField = createTextField(placeholder: "Email Address", keyboardType: .emailAddress)
        let phoneTextField = createTextField(placeholder: "Phone Number", keyboardType: .numberPad)
        let passwordTextField = createTextField(placeholder: "Password", isSecure: true)

        let signUpButton = createButton(title: "Sign up", backgroundColor: .orange, action: #selector(handleSignUp))

        let loginLabel = UILabel()
        loginLabel.text = "Already have an account?"
        loginLabel.textColor = .gray

        let loginButton = UIButton()
        loginButton.setTitle("Log in", for: .normal)
        loginButton.setTitleColor(.orange, for: .normal)
        loginButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [backButton, titleLabel, subtitleLabel, nameTextField, emailTextField, phoneTextField, passwordTextField, signUpButton, loginLabel, loginButton])
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.alignment = .center
        view.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            nameTextField.widthAnchor.constraint(equalToConstant: 300),
            emailTextField.widthAnchor.constraint(equalToConstant: 300),
            phoneTextField.widthAnchor.constraint(equalToConstant: 300),
            passwordTextField.widthAnchor.constraint(equalToConstant: 300),
            signUpButton.widthAnchor.constraint(equalToConstant: 300)
        ])
    }

    @objc private func goBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func handleSignUp() {
        print("Sign-up button pressed")
    }

    private func createTextField(placeholder: String, keyboardType: UIKeyboardType = .default, isSecure: Bool = false) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.keyboardType = keyboardType
        textField.isSecureTextEntry = isSecure
        return textField
    }

    private func createButton(title: String, backgroundColor: UIColor, action: Selector) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.backgroundColor = backgroundColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }
}

