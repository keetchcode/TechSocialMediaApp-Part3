//
//  EditPostViewController.swift
//  techSocialMediaApp
//
//  Created by Wesley Keetch on 2/21/25.
//

import UIKit

class EditPostViewController: UIViewController {
  var post: Post?
  var onPostUpdated: ((Post) -> Void)?

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    setupUI()
  }

  private func setupUI() {
  }

  private func saveChanges() {
    guard let post = post else { return }

    let newTitle = "Updated Title"
    let newBody = "Updated Body"

    Task {
      do {
        let updatedPost = try await PostService.shared.editPost(postID: post.postID, newTitle: newTitle, newBody: newBody)
        onPostUpdated?(updatedPost)
        dismiss(animated: true)
      } catch {
        print("❌ Failed to update post: \(error.localizedDescription)")
      }
    }
  }
}
