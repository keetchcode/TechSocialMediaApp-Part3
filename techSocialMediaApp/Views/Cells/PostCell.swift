//
//  PostCell.swift
//  techSocialMediaApp
//
//  Created by Wesley Keetch on 2/5/25.
//

import UIKit

class PostCell: UICollectionViewCell {

  private let profileImageView = UIImageView()
  private let titleLabel = UILabel()
  private let bodyLabel = UILabel()
  private let likeButton = UIButton(type: .system) // ✅ Like Button
  private let likeCountLabel = UILabel()
  private let commentCountLabel = UILabel()
  private let dateLabel = UILabel()

  var onLikeTapped: (() -> Void)? // ✅ Closure for Like Action

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
    styleCard()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // ✅ Apply a card-like style
  private func styleCard() {
    contentView.backgroundColor = .systemBackground
    contentView.layer.cornerRadius = 12
    contentView.layer.masksToBounds = false

    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.2
    layer.shadowOffset = CGSize(width: 0, height: 2)
    layer.shadowRadius = 8
    layer.shouldRasterize = true
    layer.rasterizationScale = UIScreen.main.scale
  }

  // ✅ Setup UI Elements
  private func setupViews() {
    profileImageView.contentMode = .scaleAspectFit
    profileImageView.layer.cornerRadius = 20
    profileImageView.clipsToBounds = true
    profileImageView.translatesAutoresizingMaskIntoConstraints = false

    titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
    titleLabel.textColor = .label
    titleLabel.translatesAutoresizingMaskIntoConstraints = false

    bodyLabel.font = UIFont.systemFont(ofSize: 14)
    bodyLabel.textColor = .secondaryLabel
    bodyLabel.numberOfLines = 2
    bodyLabel.translatesAutoresizingMaskIntoConstraints = false

    likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal) // ✅ Use SF Symbol
    likeButton.tintColor = .gray
    likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
    likeButton.translatesAutoresizingMaskIntoConstraints = false

    likeCountLabel.font = UIFont.systemFont(ofSize: 14)
    likeCountLabel.textColor = .secondaryLabel
    likeCountLabel.translatesAutoresizingMaskIntoConstraints = false

    commentCountLabel.font = UIFont.systemFont(ofSize: 14)
    commentCountLabel.textColor = .secondaryLabel
    commentCountLabel.translatesAutoresizingMaskIntoConstraints = false

    dateLabel.font = UIFont.systemFont(ofSize: 12)
    dateLabel.textColor = .systemGray
    dateLabel.translatesAutoresizingMaskIntoConstraints = false

    contentView.addSubview(profileImageView)
    contentView.addSubview(titleLabel)
    contentView.addSubview(bodyLabel)
    contentView.addSubview(likeButton)
    contentView.addSubview(likeCountLabel)
    contentView.addSubview(commentCountLabel)
    contentView.addSubview(dateLabel)

    // ✅ Set Constraints
    NSLayoutConstraint.activate([
      profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
      profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
      profileImageView.widthAnchor.constraint(equalToConstant: 40),
      profileImageView.heightAnchor.constraint(equalToConstant: 40),

      titleLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
      titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
      titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),

      bodyLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
      bodyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
      bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),

      likeButton.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12), // ✅ Place Like Button
      likeButton.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 8),
      likeButton.widthAnchor.constraint(equalToConstant: 24),
      likeButton.heightAnchor.constraint(equalToConstant: 24),

      likeCountLabel.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 8),
      likeCountLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),

      commentCountLabel.leadingAnchor.constraint(equalTo: likeCountLabel.trailingAnchor, constant: 16),
      commentCountLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),

      dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
      dateLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),

      contentView.bottomAnchor.constraint(equalTo: likeButton.bottomAnchor, constant: 12)
    ])
  }

  // ✅ Configure Cell Data
  func configure(with post: Post) {
    titleLabel.text = post.title
    bodyLabel.text = post.body
    likeCountLabel.text = "\(post.likes)"
    commentCountLabel.text = "💬 \(post.numComments)"
    dateLabel.text = post.formattedDate

    if let profileImageURL = post.profileImageUrl, let url = URL(string: profileImageURL) {
        loadImage(from: url)
    } else {
        profileImageView.image = UIImage(systemName: "person.circle.fill") // ✅ Default Profile Image
    }
  }

  // ✅ Load Profile Image
  private func loadImage(from url: URL) {
    DispatchQueue.global().async {
      if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
        DispatchQueue.main.async {
          self.profileImageView.image = image
        }
      }
    }
  }

  // ✅ Handle Like Tap
  @objc private func didTapLike() {
    onLikeTapped?()
  }
}
