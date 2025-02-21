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
  private let likeButton = UIButton(type: .system)
  private let likeCountLabel = UILabel()
  private let commentCountLabel = UILabel()
  private let dateLabel = UILabel()
  
  private let commentButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(UIImage(systemName: "bubble.right.fill"), for: .normal)
    button.tintColor = .gray
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  var onLikeTapped: (() -> Void)?
  var onCommentTapped: (() -> Void)?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
    styleCard()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
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
    
    likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
    likeButton.tintColor = .gray
    likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
    likeButton.translatesAutoresizingMaskIntoConstraints = false
    
    likeCountLabel.font = UIFont.systemFont(ofSize: 14)
    likeCountLabel.textColor = .secondaryLabel
    likeCountLabel.translatesAutoresizingMaskIntoConstraints = false
    
    commentButton.setImage(UIImage(systemName: "bubble.right.fill"), for: .normal)
    commentButton.tintColor = .gray
    commentButton.translatesAutoresizingMaskIntoConstraints = false
    commentButton.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
    
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
    contentView.addSubview(commentButton)
    contentView.addSubview(commentCountLabel)
    contentView.addSubview(dateLabel)
    
    NSLayoutConstraint.activate([
      profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
      profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
      profileImageView.widthAnchor.constraint(equalToConstant: 24),
      profileImageView.heightAnchor.constraint(equalToConstant: 24),
      
      titleLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
      titleLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
      titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
      
      bodyLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
      bodyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
      bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
      
      likeButton.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
      likeButton.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 8),
      likeButton.widthAnchor.constraint(equalToConstant: 24),
      likeButton.heightAnchor.constraint(equalToConstant: 24),
      
      likeCountLabel.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 8),
      likeCountLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
      
      commentButton.leadingAnchor.constraint(equalTo: likeCountLabel.trailingAnchor, constant: 16),
      commentButton.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
      commentButton.widthAnchor.constraint(equalToConstant: 24),
      commentButton.heightAnchor.constraint(equalToConstant: 24),
      
      commentCountLabel.leadingAnchor.constraint(equalTo: commentButton.trailingAnchor, constant: 6),
      commentCountLabel.centerYAnchor.constraint(equalTo: commentButton.centerYAnchor),
      
      dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
      dateLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
      
      contentView.bottomAnchor.constraint(equalTo: likeButton.bottomAnchor, constant: 12)
    ])
  }
  
  // Configure Cell Data
  func configure(with post: Post) {
    titleLabel.text = post.title
    bodyLabel.text = post.body
    likeCountLabel.text = "\(post.likes)"
    commentCountLabel.text = "\(post.numComments)"
    dateLabel.text = post.formattedDate
    
    if let profileImageURL = post.profileImageUrl, let url = URL(string: profileImageURL) {
      loadImage(from: url)
    } else {
      profileImageView.image = UIImage(systemName: "person.circle.fill")
    }
  }
  
  // Load Profile Image
  private func loadImage(from url: URL) {
    DispatchQueue.global().async {
      if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
        DispatchQueue.main.async {
          self.profileImageView.image = image
        }
      }
    }
  }
  
  @objc private func didTapComment() {
    onCommentTapped?()
  }
  
  @objc private func didTapLike() {
    onLikeTapped?()
  }
}
