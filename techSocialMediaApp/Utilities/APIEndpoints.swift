//
//  APIEndpoints.swift
//  techSocialMediaApp
//
//  Created by Wesley Keetch on 2/5/25.
//

import Foundation

struct APIEndpoints {
  static let baseURL = "https://social-media-app.ryanplitt.com"
  
  // Authentication
  static let signIn = "\(baseURL)/signIn"
  static let updateProfile = "\(baseURL)/updateProfile"
  
  // User Profile
  static let userProfile = "\(baseURL)/userProfile"
  static let userPosts = "\(baseURL)/userPosts"
  
  // Posts
  static let posts = "\(baseURL)/posts"
  static let createPost = "\(baseURL)/createPost"
  static let editPost = "\(baseURL)/editPost"
  
  static func deletePost(postID: Int) -> String {
    return "\(baseURL)/post?postid=\(postID)"
  }
  // Likes & Comments
  static let updateLikes = "\(baseURL)/updateLikes"
  static let getComments = "\(baseURL)/comments"
  static let createComment = "\(baseURL)/createComment"
  
  // Helper to add authentication headers
  //  static func getAuthHeaders() -> [String: String] {
  //    if let userSecret = KeychainService.shared.get("userSecret") {
  //      return ["userSecret": userSecret, "Content-Type": "application/json"]
  //    }
  //    return ["Content-Type": "application/json"]
  //  }
  
  // ✅ FIX: Use Authorization Header (Bearer Token)
  static func getAuthHeaders() -> [String: String] {
    guard let userSecret = KeychainService.shared.get("userSecret") else {
      print("❌ No userSecret found in Keychain")
      return [:]
    }
    
    print("📡 Using userSecret in Authorization Header")
    
    // ✅ Send `userSecret` as Bearer token in `Authorization`
    return [
      "Authorization": "Bearer \(userSecret)",
      "Content-Type": "application/json"
    ]
  }
}
