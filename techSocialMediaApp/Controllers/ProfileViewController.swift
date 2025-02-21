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
    setupProfileImageView()

    view.backgroundColor = UIColor.systemBackground
    userNameLabel.textColor = UIColor.label
    postCountLabel.textColor = UIColor.secondaryLabel
    followerCountLabel.textColor = UIColor.secondaryLabel
    followingCountLabel.textColor = UIColor.secondaryLabel
    bioLabel.textColor = UIColor.secondaryLabel
  }

  func loadUserProfile() {
    print("📡 Attempting to fetch user profile...")

    Task {
      do {
        let user = try await UserService().fetchUserProfile()
        print("User data received: \(user)")
        updateUI(with: user)
      } catch {
        print("Error fetching profile: \(error.localizedDescription)")
      }
    }
  }

  // Update UI with fetched data on the main thread
  func updateUI(with user: User) {
    DispatchQueue.main.async { // Ensure UI updates run on the main thread
      print("Updating UI with user data...")

      self.userNameLabel.text = user.userName
      self.bioLabel.text = user.bio ?? "No bio available"
      self.postCountLabel.text = "\(user.posts?.count ?? 0) Posts"
      self.followerCountLabel.text = "\(user.followers ?? 0) Followers"
      self.followingCountLabel.text = "\(user.following ?? 0) Following"

      if let profileImageURL = user.profileImageUrl, let url = URL(string: profileImageURL) {
        self.loadProfileImage(from: url)
      } else {
        self.profileImageView.image = UIImage(systemName: "person.circle.fill")
      }
    }
  }

  func loadProfileImage(from url: URL) {
    DispatchQueue.global().async {
      if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
        DispatchQueue.main.async {
          self.profileImageView.image = image
        }
      }
    }
  }

  func setupProfileImageView() {
    profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
    profileImageView.clipsToBounds = true
    profileImageView.contentMode = .scaleAspectFill
    profileImageView.layer.borderWidth = 2
    profileImageView.layer.borderColor = UIColor.lightGray.cgColor
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
    let settingsButton = UIBarButtonItem(
      image: UIImage(systemName: "gearshape"),
      style: .plain,
      target: self,
      action: #selector(didTapSettings)
    )
    navigationItem.rightBarButtonItem = settingsButton
  }

  @objc func didTapSettings() {
    let settingsVC = UIStoryboard(name: "Main", bundle: nil)
      .instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
    navigationController?.pushViewController(settingsVC, animated: true)
  }
}
