//
//  User.swift
//  techSocialMediaApp
//
//  Created by Brayden Lemke on 10/25/22.
//

import Foundation

struct User: Decodable, Encodable {
  var firstName: String
  var lastName: String
  var email: String
  var userUUID: UUID
  var secret: UUID
  var userName: String
  var bio: String?
  var techInterests: String?
  var profileImageUrl: String?
  var posts: [Post]?
  var followers: Int?
  var following: Int?
  
  static var current: User?
}
