//
//  CommentCell.swift
//  techSocialMediaApp
//
//  Created by Wesley Keetch on 2/5/25.
//

import UIKit

class CommentCell: UITableViewCell {

  private let userNameLabel = UILabel()
  private let commentBodyLabel = UILabel()
  private let dateLabel = UILabel()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupViews()
    styleCard()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Card Style
  private func styleCard() {
    contentView.backgroundColor = .systemBackground
    contentView.layer.cornerRadius = 12
    contentView.layer.masksToBounds = false
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.1
    layer.shadowOffset = CGSize(width: 0, height: 2)
    layer.shadowRadius = 4
    layer.shouldRasterize = true
    layer.rasterizationScale = UIScreen.main.scale
  }

  // MARK: - 🛠️ Setup Views and Constraints
  private func setupViews() {
    userNameLabel.font = UIFont.boldSystemFont(ofSize: 14)
    userNameLabel.textColor = .label
    userNameLabel.translatesAutoresizingMaskIntoConstraints = false

    commentBodyLabel.font = UIFont.systemFont(ofSize: 14)
    commentBodyLabel.textColor = .secondaryLabel
    commentBodyLabel.numberOfLines = 0
    commentBodyLabel.translatesAutoresizingMaskIntoConstraints = false

    dateLabel.font = UIFont.systemFont(ofSize: 12)
    dateLabel.textColor = .systemGray
    dateLabel.translatesAutoresizingMaskIntoConstraints = false

    contentView.addSubview(userNameLabel)
    contentView.addSubview(commentBodyLabel)
    contentView.addSubview(dateLabel)

    NSLayoutConstraint.activate([
      userNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
      userNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
      userNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),

      commentBodyLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 4),
      commentBodyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
      commentBodyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),

      dateLabel.topAnchor.constraint(equalTo: commentBodyLabel.bottomAnchor, constant: 4),
      dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
      dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
    ])
  }

  // MARK: - 📌 Configure Method
  func configure(with comment: Comment) {
    userNameLabel.text = comment.userName
    commentBodyLabel.text = comment.body
    dateLabel.text = comment.createdDate
  }
}
