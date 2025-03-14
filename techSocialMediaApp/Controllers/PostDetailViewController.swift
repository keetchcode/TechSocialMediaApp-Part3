//
//  PostDetailViewController.swift
//  techSocialMediaApp
//
//  Created by Wesley Keetch on 2/5/25.
//

import UIKit

class PostDetailViewController: UIViewController {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var bodyLabel: UILabel!
  @IBOutlet weak var likeCountLabel: UILabel!
  @IBOutlet weak var authorLabel: UILabel!
  @IBOutlet weak var commentCountLabel: UILabel!
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var commentsTableView: UITableView!
  @IBOutlet weak var likeButton: UIButton!
  @IBOutlet weak var commentButton: UIButton!
  
  var post: Post?
  private var comments: [Comment] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    displayPostDetails()
    setupTableView()
    fetchComments()
    profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
    profileImageView.layer.masksToBounds = true
    profileImageView.contentMode = .scaleAspectFill

    setupButtons()
  }

  // MARK: - Display Post Details
  private func displayPostDetails() {
    guard let post = post else { return }

    titleLabel.text = post.title
    bodyLabel.text = post.body
    authorLabel.text = "@\(post.authorUserName)"
    likeCountLabel.text = "\(post.likes)"
    commentCountLabel.text = "\(post.numComments)"
    dateLabel.text = post.formattedDate

    likeButton.tintColor = post.userLiked ? .systemBlue : .gray

    if let profileImageUrl = post.profileImageUrl, let url = URL(string: profileImageUrl) {
      loadImage(from: url)
    } else {
      profileImageView.image = UIImage(named: "default_profile")
    }
  }

  private func setupButtons() {

    likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
    commentButton.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)

    likeCountLabel.translatesAutoresizingMaskIntoConstraints = false
    commentCountLabel.translatesAutoresizingMaskIntoConstraints = false

  }
  private func loadImage(from url: URL) {
    DispatchQueue.global().async {
      if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
        DispatchQueue.main.async {
          self.profileImageView.image = image
        }
      } else {
        DispatchQueue.main.async {
          self.profileImageView.image = UIImage(named: "default_profile") 
        }
      }
    }
  }

  // MARK: - Setup Table View
  func setupTableView() {
    commentsTableView.dataSource = self
    commentsTableView.delegate = self
    commentsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "CommentCell")
    commentsTableView.rowHeight = UITableView.automaticDimension
    commentsTableView.estimatedRowHeight = 80
  }

  @IBAction func likeButtonTapped(_ sender: UIButton) {
    guard let post = post else { return }

    Task {
      do {
        let updatedPost = try await PostService.shared.toggleLike(postID: post.postID, userLiked: !post.userLiked)
        DispatchQueue.main.async {
          self.post = updatedPost
          self.likeCountLabel.text = "\(updatedPost.likes)"
        }
      } catch {
        print("❌ Failed to update like: \(error.localizedDescription)")
      }
    }
  }

  @objc private func didTapLike() {
    guard let post = post else { return }

    Task {
      do {
        let updatedPost = try await PostService.shared.toggleLike(postID: post.postID, userLiked: !post.userLiked)
        DispatchQueue.main.async {
          self.post = updatedPost
          self.likeCountLabel.text = "\(updatedPost.likes)"
          self.likeButton.tintColor = updatedPost.userLiked ? .systemBlue : .gray
        }
      } catch {
        print("❌ Failed to update like: \(error.localizedDescription)")
      }
    }
  }

  @IBAction func commentButtonTapped(_ sender: UIButton) {
  }

  @objc private func didTapComment() {
    guard let post = post else { return }

    let commentsVC = CommentsViewController()
    commentsVC.postID = post.postID
    present(commentsVC, animated: true)
  }

  // MARK: - Fetch Comments from Server
  private func fetchComments() {
    guard let post = post else {
      print("⚠️ Missing post information")
      return
    }
    
    Task {
      do {
        print("📡 Fetching comments for postID: \(post.postID)")
        let fetchedComments = try await CommentService.shared.fetchComments(for: post.postID)

        DispatchQueue.main.async {
          self.comments = fetchedComments
          self.commentCountLabel.text = "\(self.comments.count)"
          self.commentsTableView.reloadData()
        }
        print("✅ Loaded \(self.comments.count) comments for post \(post.postID)")

      } catch {
        print("❌ Failed to fetch comments: \(error.localizedDescription)")
        DispatchQueue.main.async {
          self.comments = [] // Default to empty state if error occurs
          self.commentsTableView.reloadData()
        }
      }
    }
  }
}

// MARK: - UITableView Data Source & Delegate
extension PostDetailViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return comments.isEmpty ? 1 : comments.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if comments.isEmpty {
      // Show "No Comments" cell
      let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
      var content = cell.defaultContentConfiguration()
      content.text = "No Comments"
      content.textProperties.alignment = .center
      content.textProperties.color = .secondaryLabel
      cell.contentConfiguration = content
      return cell
    }

    // Show actual comment cell
    let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
    let comment = comments[indexPath.row]

    var content = cell.defaultContentConfiguration()
    content.secondaryText = comment.userName
    content.text = comment.body
    cell.contentConfiguration = content
    return cell
  }
}
