//
//  ProfileViewController.swift
//  techSocialMediaApp
//
//  Created by Wesley Keetch on 2/5/25.
//

import UIKit

class ProfileViewController: UIViewController {

  @IBOutlet weak var profileImageView: UIImageView!

  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var postCountLabel: UILabel!
  @IBOutlet weak var followerCountLabel: UILabel!
  @IBOutlet weak var followingCountLabel: UILabel!
  @IBOutlet weak var bioLabel: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()

    setupNavigationBar()

    // Light/Dark mode added
    view.backgroundColor = UIColor.systemBackground
    userNameLabel.textColor = UIColor.label
    postCountLabel.textColor = UIColor.secondaryLabel
    followerCountLabel.textColor = UIColor.secondaryLabel
    followingCountLabel.textColor = UIColor.secondaryLabel
    bioLabel.textColor = UIColor.secondaryLabel
  }


  func setupProfileImageView() {
    profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
    profileImageView.clipsToBounds = true
    profileImageView.contentMode = .scaleAspectFill
    profileImageView.layer.borderWidth = 2
    profileImageView.layer.borderColor = UIColor.lightGray.cgColor
  }

  func loadUserProfileImage() {
    // Replace with actual image loading logic (from URL or local storage)
    if let profileImageURL = URL(string: "https://example.com/profile.jpg") {
      DispatchQueue.global().async {
        if let imageData = try? Data(contentsOf: profileImageURL) {
          DispatchQueue.main.async {
            self.profileImageView.image = UIImage(data: imageData)
          }
        }
      }
    } else {
      profileImageView.image = UIImage(systemName: "person.circle.fill") // Placeholder image
    }
  }

  @IBAction func logoutButtonTapped(_ sender: UIButton) {
    // Clear stored credentials
    KeychainService.shared.delete("userSecret")
    UserDefaults.standard.removeObject(forKey: "userUUID")
    UserDefaults.standard.removeObject(forKey: "userName")

    // Navigate back to Sign-In screen
    let authVC = UIStoryboard(name: "Main", bundle: .main)
      .instantiateViewController(withIdentifier: "AuthViewController")
    let viewControllers = [authVC]
    self.navigationController?.setViewControllers(viewControllers, animated: true)
  }

  func setupNavigationBar() {
    // ✅ Create a UIBarButtonItem with SF Symbol "gearshape"
    let settingsButton = UIBarButtonItem(
      image: UIImage(systemName: "gearshape"), // SF Symbol for settings
      style: .plain,
      target: self,
      action: #selector(didTapSettings)
    )

    // ✅ Set the button to the right side of the navigation bar
    navigationItem.rightBarButtonItem = settingsButton
  }

  @objc func didTapSettings() {
    // ✅ Navigate to SettingsViewController
    let settingsVC = UIStoryboard(name: "Main", bundle: nil)
      .instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController

    navigationController?.pushViewController(settingsVC, animated: true)
  }
}
