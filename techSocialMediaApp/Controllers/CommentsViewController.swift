//
//  CommentsViewController.swift
//  techSocialMediaApp
//
//  Created by Wesley Keetch on 2/5/25.
//

import UIKit

class CommentsViewController: UIViewController {

  var postID: Int?

  private let textView: UITextView = {
    let tv = UITextView()
    tv.font = UIFont.systemFont(ofSize: 16)
    tv.layer.cornerRadius = 8
    tv.layer.borderWidth = 1
    tv.layer.borderColor = UIColor.systemGray4.cgColor
    tv.translatesAutoresizingMaskIntoConstraints = false
    return tv
  }()

  private let submitButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Comment", for: .normal)
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    button.tintColor = .white
    button.backgroundColor = .systemBrown
    button.layer.cornerRadius = 8
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  private let placeholderLabel: UILabel = {
    let label = UILabel()
    label.text = "Write a comment..."
    label.font = UIFont.systemFont(ofSize: 16)
    label.textColor = .systemGray3
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    setupUI()

    submitButton.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)

    // Add Tap Gesture to Dismiss Keyboard
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    view.addGestureRecognizer(tapGesture)

    textView.delegate = self
  }

  private func setupUI() {
    view.addSubview(textView)
    view.addSubview(placeholderLabel)
    view.addSubview(submitButton)

    NSLayoutConstraint.activate([
      textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
      textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      textView.heightAnchor.constraint(equalToConstant: 100),

      placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 8),
      placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 8),

      submitButton.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 16),
      submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      submitButton.heightAnchor.constraint(equalToConstant: 44)
    ])
  }

  @objc private func didTapSubmit() {
    guard let postID = postID, let commentText = textView.text, !commentText.isEmpty else {
      showAlert(message: "Comment cannot be empty!")
      return
    }

    print("📌 Attempting to post comment: '\(commentText)' for postID: \(postID)")

    Task {
      do {
        try await PostService.shared.createComment(for: postID, comment: commentText)

        DispatchQueue.main.async {
          print("✅ Comment successfully posted for postID: \(postID)")
          self.textView.text = ""
          self.placeholderLabel.isHidden = false
          self.dismiss(animated: true)
        }
      } catch {
        DispatchQueue.main.async {
          print("❌ Error posting comment: \(error)")
          self.showAlert(message: "Failed to post comment. Please try again.")
        }
      }
    }
  }

  @objc private func dismissKeyboard() {
    view.endEditing(true)
  }

  private func showAlert(message: String) {
    let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    present(alert, animated: true)
  }
}

// ✅ **Handle Placeholder Visibility**
extension CommentsViewController: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    placeholderLabel.isHidden = !textView.text.isEmpty
  }
}
