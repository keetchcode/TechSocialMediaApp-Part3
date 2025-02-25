//
//  SettingsViewController.swift
//  techSocialMediaApp
//
//  Created by Wesley Keetch on 2/7/25.
//

import UIKit

class SettingsViewController: UIViewController {

  private let userNameTextField = UITextField()
  private let firstNameTextField = UITextField()
  private let lastNameTextField = UITextField()
  private let bioTextField = UITextField()
  private let techInterestsTextField = UITextField()
  private let saveButton = UIButton(type: .system)
  private let signOutButton = UIButton(type: .system)

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    title = "Settings"

    setupUI()
    loadUserProfile()
  }

  private func setupUI() {
    userNameTextField.placeholder = "Enter Username"
    firstNameTextField.placeholder = "Enter First Name"
    lastNameTextField.placeholder = "Enter Last Name"
    bioTextField.placeholder = "Enter Bio"
    techInterestsTextField.placeholder = "Enter Tech Interests"

    let textFields = [userNameTextField, firstNameTextField, lastNameTextField, bioTextField, techInterestsTextField]

    textFields.forEach {
      $0.translatesAutoresizingMaskIntoConstraints = false
      $0.borderStyle = .roundedRect
      $0.layer.cornerRadius = 8
      $0.layer.borderWidth = 1
      $0.layer.borderColor = UIColor.systemGray4.cgColor
      view.addSubview($0)
    }

    saveButton.setTitle("Save Changes", for: .normal)
    saveButton.addTarget(self, action: #selector(saveChanges), for: .touchUpInside)

    signOutButton.setTitle("Sign Out", for: .normal)
    signOutButton.setTitleColor(.red, for: .normal)
    signOutButton.addTarget(self, action: #selector(signOut), for: .touchUpInside)

    [saveButton, signOutButton].forEach {
      $0.translatesAutoresizingMaskIntoConstraints = false
      $0.layer.cornerRadius = 8
      $0.backgroundColor = .brown
      $0.setTitleColor(.white, for: .normal)
      view.addSubview($0)
    }

    NSLayoutConstraint.activate([
      userNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
      userNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      userNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

      firstNameTextField.topAnchor.constraint(equalTo: userNameTextField.bottomAnchor, constant: 12),
      firstNameTextField.leadingAnchor.constraint(equalTo: userNameTextField.leadingAnchor),
      firstNameTextField.trailingAnchor.constraint(equalTo: userNameTextField.trailingAnchor),

      lastNameTextField.topAnchor.constraint(equalTo: firstNameTextField.bottomAnchor, constant: 12),
      lastNameTextField.leadingAnchor.constraint(equalTo: firstNameTextField.leadingAnchor),
      lastNameTextField.trailingAnchor.constraint(equalTo: firstNameTextField.trailingAnchor),

      bioTextField.topAnchor.constraint(equalTo: lastNameTextField.bottomAnchor, constant: 12),
      bioTextField.leadingAnchor.constraint(equalTo: lastNameTextField.leadingAnchor),
      bioTextField.trailingAnchor.constraint(equalTo: lastNameTextField.trailingAnchor),

      techInterestsTextField.topAnchor.constraint(equalTo: bioTextField.bottomAnchor, constant: 12),
      techInterestsTextField.leadingAnchor.constraint(equalTo: bioTextField.leadingAnchor),
      techInterestsTextField.trailingAnchor.constraint(equalTo: bioTextField.trailingAnchor),

      saveButton.topAnchor.constraint(equalTo: techInterestsTextField.bottomAnchor, constant: 20),
      saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      saveButton.widthAnchor.constraint(equalToConstant: 200),
      saveButton.heightAnchor.constraint(equalToConstant: 44),

      signOutButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 20),
      signOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      signOutButton.widthAnchor.constraint(equalToConstant: 200),
      signOutButton.heightAnchor.constraint(equalToConstant: 44)
    ])
  }

  private func loadUserProfile() {
    guard let user = User.current else { return }
    userNameTextField.text = user.userName
    firstNameTextField.text = user.firstName
    lastNameTextField.text = user.lastName
    bioTextField.text = user.bio
    techInterestsTextField.text = user.techInterests
  }

  @objc private func saveChanges() {
    guard let user = User.current else { return }

    let updatedUser = User(
      firstName: firstNameTextField.text ?? user.firstName,
      lastName: lastNameTextField.text ?? user.lastName,
      email: user.email,
      userUUID: user.userUUID,
      secret: user.secret,
      userName: userNameTextField.text ?? user.userName,
      bio: bioTextField.text,
      techInterests: techInterestsTextField.text,
      profileImageUrl: user.profileImageUrl,
      posts: user.posts,
      followers: user.followers,
      following: user.following
    )

    Task {
      do {
        try await UserService.shared.updateUserProfile(
          userName: updatedUser.userName,
          bio: updatedUser.bio ?? "",
          techInterests: updatedUser.techInterests ?? ""
        )
        DispatchQueue.main.async {
          User.current = updatedUser
          self.navigationController?.popViewController(animated: true)
        }
      } catch {
        DispatchQueue.main.async {
          self.showErrorAlert(message: "Failed to update profile. Please try again.")
        }
        print("❌ Error updating profile: \(error.localizedDescription)")
      }
    }
  }

  @objc private func signOut() {
    let alert = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .alert)

    // YES: Confirm Sign-Out
    alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
      self.performSignOut()
    }))

    // NO: Cancel Action
    alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

    present(alert, animated: true, completion: nil)
  }

  // ✅ Handles Logout and Navigation
  private func performSignOut() {
    AuthenticationService().logout()

    DispatchQueue.main.async {
      // Navigate to AuthenticationViewController
      let authVC = AuthViewController()
      authVC.modalPresentationStyle = .fullScreen
      self.present(authVC, animated: true, completion: nil)
    }
  }

  // MARK: - Show Error Alert
  private func showErrorAlert(message: String) {
    let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    present(alert, animated: true, completion: nil)
  }
}
