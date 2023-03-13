//
//  LoginViewController.swift
//  DB challenge
//
//  Created by Zofia Drabek on 07.03.23.
//

import UIKit

class LoginViewController: UIViewController {
    let button = UIButton(configuration: UIButton.Configuration.borderedProminent())
    let userNameField = UITextField()
    let errorLabel = UILabel()
    let didLogin: (String) -> Void

    init(didLogin: @escaping (String) -> Void) {
        self.didLogin = didLogin
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white

        setupTextField()
        setupErrorLabel()
        setupButton()
    }

    private func setupTextField() {
        view.addSubview(userNameField)
        userNameField.borderStyle = .roundedRect
        userNameField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userNameField.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            userNameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            userNameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }

    private func setupErrorLabel() {
        view.addSubview(errorLabel)
        errorLabel.numberOfLines = 0
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: userNameField.bottomAnchor, constant: 4),
            errorLabel.leadingAnchor.constraint(equalTo: userNameField.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: userNameField.trailingAnchor),
        ])
    }

    private func setupButton() {
        view.addSubview(button)
        button.setTitle("Login", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 32),
            button.leadingAnchor.constraint(equalTo: userNameField.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: userNameField.trailingAnchor),
        ])
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }
    
    @objc
    func loginButtonTapped(_ sender: UIButton) {
        if let userID = userNameField.text, !userID.isEmpty {
            didLogin(userID)
        } else {
            errorLabel.text = "User ID not valid"
        }
    }
}
