//
//  Post.swift
//  techSocialMediaApp
//
//  Created by Wesley Keetch on 2/5/25.
//

import Foundation

struct Post: Codable {
  let postID: Int
  let title: String
  let body: String
  let authorUserName: String
  let authorUserId: UUID
  let likes: Int
  let userLiked: Bool
  let numComments: Int
  let createdDate: String
  
  /**
   Custom Coding Keys to match API response.
   */
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
  }
}
