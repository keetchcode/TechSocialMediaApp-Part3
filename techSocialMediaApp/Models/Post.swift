//
//  Post.swift
//  techSocialMediaApp
//
//  Created by Wesley Keetch on 2/5/25.
//

import Foundation

struct Post: Codable, Hashable {
  let postID: Int
  let title: String
  let body: String
  let authorUserName: String
  let authorUserId: String  // ✅ Decode as String, then convert to UUID if needed
  let likes: Int
  let userLiked: Bool
  let numComments: Int
  let createdDate: Date
  let postImageUrl: String?
  let profileImageUrl: String?
  let tags: [String]?
  let likeIds: [String]  // ✅ Match API response format

  /// **Formatted Date String for UI Display**
  var formattedDate: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd" // Match API format
    return formatter.string(from: createdDate)
  }

  // ✅ **Custom Decoder to Handle API Response**
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.postID = try container.decode(Int.self, forKey: .postID)
    self.title = try container.decode(String.self, forKey: .title)
    self.body = try container.decode(String.self, forKey: .body)
    self.authorUserName = try container.decode(String.self, forKey: .authorUserName)
    self.authorUserId = try container.decode(String.self, forKey: .authorUserId) // ✅ Decode as String

    self.likes = try container.decode(Int.self, forKey: .likes)
    self.userLiked = try container.decode(Bool.self, forKey: .userLiked)
    self.numComments = try container.decode(Int.self, forKey: .numComments)
    self.postImageUrl = try container.decodeIfPresent(String.self, forKey: .postImageUrl)
    self.profileImageUrl = try container.decodeIfPresent(String.self, forKey: .profileImageUrl)
    self.tags = try container.decodeIfPresent([String].self, forKey: .tags)
    self.likeIds = try container.decodeIfPresent([String].self, forKey: .likeIds) ?? [] // ✅ Default to empty array

    // ✅ **Fix Date Decoding**
    let dateString = try container.decode(String.self, forKey: .createdDate)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd" // Match API format

    if let parsedDate = dateFormatter.date(from: dateString) {
      self.createdDate = parsedDate
    } else {
      throw DecodingError.dataCorruptedError(forKey: .createdDate, in: container, debugDescription: "Invalid date format: \(dateString)")
    }
  }

  // ✅ **Match API JSON Keys**
  enum CodingKeys: String, CodingKey {
    case postID = "postid"
    case title
    case body
    case authorUserName
    case authorUserId
    case likes
    case userLiked
    case numComments
    case createdDate
    case postImageUrl = "post_image_url"
    case profileImageUrl = "profile_image_url"
    case tags
    case likeIds = "likeIds"  // ✅ Match API key
  }
}
