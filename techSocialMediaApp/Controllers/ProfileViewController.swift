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
  @IBOutlet weak var actualNameLabel: UILabel!
  @IBOutlet weak var techInterestsLabel: UILabel!
  
  @IBOutlet weak var postsTableView: UITableView!
  
  private var userPosts: [Post] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    setupTableView()
    loadUserProfile()
    fetchUserPosts()
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      image: UIImage(systemName: "gearshape.fill"),
      style: .plain,
      target: self,
      action: #selector(didTapSettings)
    )
    navigationItem.rightBarButtonItem?.tintColor = .tintColor
  }
  
  // MARK: - Setup UI
  private func setupUI() {
    profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
    profileImageView.clipsToBounds = true
    profileImageView.contentMode = .scaleAspectFill
    profileImageView.layer.borderWidth = 2
    profileImageView.layer.borderColor = UIColor.lightGray.cgColor
    
    postsTableView.dataSource = self
    postsTableView.delegate = self
    postsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "PostCell")
  }
  
  // MARK: - Fetch User Profile
  private func loadUserProfile() {
    print("📡 Fetching user profile...")
    
    Task {
      do {
        let user = try await UserService.shared.fetchUserProfile()
        User.current = user
        DispatchQueue.main.async {
          self.updateUI(with: user)
        }
      } catch {
        print("❌ Error fetching profile: \(error.localizedDescription)")
      }
    }
  }
  
  // MARK: - Setup Table View
  private func setupTableView() {
    postsTableView.dataSource = self
    postsTableView.delegate = self
    postsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "PostCell")
  }
  
  private func updateUI(with user: User) {
    print("✅ Updating profile UI...")
    
    userNameLabel.text = "@\(user.userName)"
    actualNameLabel.text = "\(user.firstName) \(user.lastName)" // ✅ Correcting to use first & last name
    bioLabel.text = user.bio ?? "No bio available"
    techInterestsLabel.text = user.techInterests ?? "No interests listed"
    
    postCountLabel.text = "\(user.posts?.count ?? 0) Posts"
    followerCountLabel.text = "\(user.followers ?? 0) Followers"
    followingCountLabel.text = "\(user.following ?? 0) Following"
    
    if let profileImageURL = user.profileImageUrl, let url = URL(string: profileImageURL) {
      loadProfileImage(from: url)
    } else {
      profileImageView.image = UIImage(systemName: "person.circle.fill")
    }
  }
  
  @objc private func didTapSettings() {
    let settingsVC = SettingsViewController()
    navigationController?.pushViewController(settingsVC, animated: true)
  }
  
  private func loadProfileImage(from url: URL) {
    DispatchQueue.global().async {
      if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
        DispatchQueue.main.async {
          self.profileImageView.image = image
        }
      }
    }
  }
  
  private func fetchUserPosts() {
    guard let user = User.current else {
      print("⚠️ User not loaded yet.")
      return
    }
    
    DispatchQueue.main.async {
      self.userPosts = user.posts ?? []
      self.postsTableView.reloadData()
    }
  }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return userPosts.isEmpty ? 1 : userPosts.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if userPosts.isEmpty {
      let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
      var content = cell.defaultContentConfiguration()
      content.text = "No posts available"
      content.textProperties.alignment = .center
      content.textProperties.color = .secondaryLabel
      cell.contentConfiguration = content
      return cell
    }
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath)
    let post = userPosts[indexPath.row]
    
    var content = cell.defaultContentConfiguration()
    content.text = post.title
    content.secondaryText = post.body
    cell.contentConfiguration = content
    
    return cell
  }
  
  // Handle post selection (edit/delete options)
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard !userPosts.isEmpty else { return }
    
    let post = userPosts[indexPath.row]
    showPostActionSheet(for: post)
  }
  
  private func showPostActionSheet(for post: Post) {
    let alertController = UIAlertController(title: "Post Options", message: nil, preferredStyle: .actionSheet)
    
    alertController.addAction(UIAlertAction(title: "Edit Post", style: .default, handler: { _ in
      self.editPost(post)
    }))
    
    alertController.addAction(UIAlertAction(title: "Delete Post", style: .destructive, handler: { _ in
      self.deletePost(post)
    }))
    
    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
    present(alertController, animated: true)
  }
}

// MARK: - Post Actions
extension ProfileViewController {
  private func editPost(_ post: Post) {
    let editVC = EditPostViewController()
    editVC.post = post
    editVC.onPostUpdated = { updatedPost in
      if let index = self.userPosts.firstIndex(where: { $0.postID == updatedPost.postID }) {
        self.userPosts[index] = updatedPost
        self.postsTableView.reloadData()
      }
    }
    present(editVC, animated: true)
  }
  
  private func deletePost(_ post: Post) {
    Task {
      do {
        try await PostService.shared.deletePost(postID: post.postID)
        DispatchQueue.main.async {
          self.userPosts.removeAll { $0.postID == post.postID }
          self.postsTableView.reloadData()
        }
        print("✅ Post deleted successfully")
      } catch {
        print("❌ Failed to delete post: \(error.localizedDescription)")
      }
    }
  }
}
