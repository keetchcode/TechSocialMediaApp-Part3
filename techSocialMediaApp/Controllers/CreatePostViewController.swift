//
//  CreatePostViewController.swift
//  techSocialMediaApp
//
//  Created by Wesley Keetch on 2/5/25.
//

import UIKit

class CreatePostViewController: UIViewController {

  private let titleTextField: UITextField = {
    let textField = UITextField()
    textField.placeholder = "Post Title"
    textField.borderStyle = .roundedRect
    textField.translatesAutoresizingMaskIntoConstraints = false
    return textField
  }()

  private let bodyTextView: UITextView = {
    let textView = UITextView()
    textView.font = UIFont.systemFont(ofSize: 16)
    textView.layer.borderColor = UIColor.lightGray.cgColor
    textView.layer.borderWidth = 1
    textView.layer.cornerRadius = 8
    textView.translatesAutoresizingMaskIntoConstraints = false
    return textView
  }()

  private let submitButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Post", for: .normal)
    button.backgroundColor = .brown
    button.setTitleColor(.white, for: .normal)
    button.layer.cornerRadius = 8
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    setupUI()
    setupActions()
  }

  private func setupUI() {
    view.addSubview(titleTextField)
    view.addSubview(bodyTextView)
    view.addSubview(submitButton)

    NSLayoutConstraint.activate([
      titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
      titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      titleTextField.heightAnchor.constraint(equalToConstant: 40),

      bodyTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 12),
      bodyTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      bodyTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      bodyTextView.heightAnchor.constraint(equalToConstant: 150),

      submitButton.topAnchor.constraint(equalTo: bodyTextView.bottomAnchor, constant: 20),
      submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      submitButton.widthAnchor.constraint(equalToConstant: 150),
      submitButton.heightAnchor.constraint(equalToConstant: 44)
    ])
  }

  private func setupActions() {
    submitButton.addAction(UIAction { [weak self] _ in
      self?.handleSubmit()
    }, for: .touchUpInside)
  }

  private func handleSubmit() {
    guard let title = titleTextField.text, !title.isEmpty,
          let body = bodyTextView.text, !body.isEmpty else {
      print("⚠️ Title and Body cannot be empty")
      return
    }

    Task {
      do {
        let newPost = try await PostService.shared.createPost(title: title, body: body)
        print("✅ Post created: \(newPost.title)")
        dismiss(animated: true)
      } catch {
        print("❌ Failed to create post: \(error.localizedDescription)")
      }
    }
  }
}
