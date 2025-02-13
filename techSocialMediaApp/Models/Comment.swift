//
//  Comment.swift
//  techSocialMediaApp
//
//  Created by Wesley Keetch on 2/5/25.
//

import Foundation

struct Comment: Codable {
  let commentID: Int
  let body: String
  let userName: String
  let userID: UUID
  let createdDate: String
  
  /**
   Custom Coding Keys to match API response.
   */
  enum CodingKeys: String, CodingKey {
    case commentID = "commentId"
    case body
    case userName
    case userID = "userId"
    case createdDate
  }
}
