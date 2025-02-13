//
//  ViewController.swift
//  techSocialMediaApp
//
//  Created by Brayden Lemke on 10/20/22.
//

import UIKit

class AuthViewController: UIViewController {
  
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var errorLabel: UILabel!
  @IBOutlet weak var signInButton: UIButton!
  
  let authenticationService = AuthenticationService()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // ✅ Hide error label initially
    errorLabel.isHidden = true
    passwordTextField.isSecureTextEntry = true
    
    // ✅ Check if the user is already signed in
    autoLoginIfPossible()
  }
  
  /**
   Automatically log in if userSecret exists in Keychain.
   */
  private func autoLoginIfPossible() {
    if let userSecret = KeychainService.shared.get("userSecret") {
      print("User already logged in with secret: \(userSecret)")
      navigateToMainApp()
    }
  }
  
  /**
   Handles the sign-in button action.
   */
  @IBAction func signInButtonTapped(_ sender: Any) {
    guard let email = emailTextField.text, !email.isEmpty,
          let password = passwordTextField.text, !password.isEmpty else {
      errorLabel.text = "Email and password cannot be empty."
      errorLabel.isHidden = false
      return
    }
    
    // ✅ Disable the sign-in button while processing
    signInButton.isEnabled = false
    errorLabel.isHidden = true
    
    Task {
      do {
        // ✅ Attempt Sign-In
        let success = try await authenticationService.signIn(email: email, password: password)
        if success {
          navigateToMainApp()
        }
      } catch {
        DispatchQueue.main.async {
          self.errorLabel.text = "Invalid username or password."
          self.errorLabel.textColor = .red // ✅ Make error text color red for visibility
          self.errorLabel.isHidden = false
          self.signInButton.isEnabled = true // ✅ Ensure button is re-enabled if login fails
        }
        print("❌ Login error: \(error)")
      }
      
      // ✅ Re-enable sign-in button after request
      signInButton.isEnabled = true
    }
  }
  
  /**
   Navigates to the main app screen after successful login.
   */
  private func navigateToMainApp() {
    let viewController = UIStoryboard(name: "Main", bundle: .main)
      .instantiateViewController(withIdentifier: "userSignedIn")
    let viewControllers = [viewController]
    self.navigationController?.setViewControllers(viewControllers, animated: true)
  }
}

