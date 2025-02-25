//
//  PostService.swift
//  techSocialMediaApp
//
//  Created by Wesley Keetch on 2/5/25.
//

import Foundation

class PostService {
  
  static let shared = PostService()
  
  private init() {}
  
  enum PostServiceError: Error {
    case invalidURL
    case unauthorized
    case serverError(statusCode: Int)
    case decodingError
    case missingUserSecret
    
  }
  
  // MARK: - GET /posts 
  func getPosts(pageNumber: Int = 0) async throws -> [Post] {
    guard let userSecret = KeychainService.shared.get("userSecret") else {
      print("❌ No userSecret found in Keychain")
      throw PostServiceError.unauthorized
    }
    
    guard let url = URL(string: "\(APIEndpoints.posts)?pageNumber=\(pageNumber)&userSecret=\(userSecret)") else {
      throw PostServiceError.invalidURL
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    print("📡 Requesting posts from: \(url.absoluteString)")
    
    do {
      let (data, response) = try await URLSession.shared.data(for: request)
      guard let httpResponse = response as? HTTPURLResponse else {
        throw PostServiceError.serverError(statusCode: 500)
      }
      
      print("📡 HTTP Status Code: \(httpResponse.statusCode)")
      
      // ✅ Debugging: Print raw JSON response
      if let jsonString = String(data: data, encoding: .utf8) {
        print("📥 Raw API Response:\n\(jsonString)")
      }
      
      switch httpResponse.statusCode {
      case 200, 201:
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601 // Ensure proper date format decoding
        
        do {
          let posts = try decoder.decode([Post].self, from: data)
          let sortedPosts = posts.sorted(by: { $0.createdDate > $1.createdDate })
          print("✅ Successfully fetched \(sortedPosts.count) posts")
          
          return sortedPosts
        } catch let decodingError {
          print("❌ JSON Decoding Error: \(decodingError.localizedDescription)")
          throw PostServiceError.decodingError
        }
        
      default:
        print("❌ Server error: Status \(httpResponse.statusCode)")
        throw PostServiceError.serverError(statusCode: httpResponse.statusCode)
      }
    } catch {
      print("❌ Unexpected Error: \(error.localizedDescription)")
      throw PostServiceError.serverError(statusCode: 500)
    }
  }
  
  // MARK: - ✅ 2. CREATE POST
  func createPost(title: String, body: String) async throws -> Post {
    guard let userSecret = KeychainService.shared.get("userSecret") else {
      throw PostServiceError.unauthorized
    }
    
    guard let url = URL(string: APIEndpoints.createPost) else {
      throw PostServiceError.invalidURL
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let requestBody: [String: Any] = [
      "userSecret": userSecret,
      "post": [
        "title": title,
        "body": body
      ]
    ]
    
    request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: .fragmentsAllowed)
    
    let (data, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse else {
      throw PostServiceError.serverError(statusCode: 500)
    }
    
    print("📡 HTTP Status Code: \(httpResponse.statusCode)")
    
    switch httpResponse.statusCode {
    case 200, 201:
      let createdPost = try JSONDecoder().decode(Post.self, from: data)
      print("✅ Post Created: \(createdPost.title)")
      return createdPost
    default:
      throw PostServiceError.serverError(statusCode: httpResponse.statusCode)
    }
  }
  
  // MARK: - ✅ 3. TOGGLE LIKE
  func toggleLike(postID: Int, userLiked: Bool) async throws -> Post {
    guard let userSecret = KeychainService.shared.get("userSecret") else {
      throw PostServiceError.unauthorized
    }
    
    guard let url = URL(string: APIEndpoints.updateLikes) else {
      throw PostServiceError.invalidURL
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let requestBody: [String: Any] = [
      "userSecret": userSecret,
      "postid": postID,
      "userLiked": userLiked // ✅ Ensure this is sent to API
    ]
    request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: .fragmentsAllowed)
    
    let (data, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse else {
      throw PostServiceError.serverError(statusCode: 500)
    }
    
    switch httpResponse.statusCode {
    case 200, 201:
      return try JSONDecoder().decode(Post.self, from: data)
    default:
      throw PostServiceError.serverError(statusCode: httpResponse.statusCode)
    }
  }
  
  // MARK: - ✅ 4. DELETE POST
  func deletePost(postID: Int) async throws {
    guard let userSecret = KeychainService.shared.get("userSecret") else {
      throw PostServiceError.unauthorized
    }
    
    guard let url = URL(string: "\(APIEndpoints.deletePost(postID: postID))?userSecret=\(userSecret)") else {
      throw PostServiceError.invalidURL
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"
    
    let (_, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse else {
      throw PostServiceError.serverError(statusCode: 500)
    }
    
    if httpResponse.statusCode == 200 {
      print("✅ Post Deleted Successfully")
    } else {
      throw PostServiceError.serverError(statusCode: httpResponse.statusCode)
    }
  }
  
  // MARK: - ✅ CREATE COMMENT (Fixed)
  func createComment(for postID: Int, comment: String) async throws {
    guard let userSecret = KeychainService.shared.get("userSecret") else {
      throw PostServiceError.unauthorized
    }
    
    guard let url = URL(string: APIEndpoints.createComment) else {
      throw PostServiceError.invalidURL
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type") // ✅ Add required header
    
    let requestBody: [String: Any] = [
      "userSecret": userSecret,  // ✅ Correctly placed userSecret
      "commentBody": comment,    // ✅ Correct key based on API docs
      "postid": postID           // ✅ Correct key for post ID
    ]
    
    // ✅ Debugging: Print request JSON
    if let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted),
       let jsonString = String(data: jsonData, encoding: .utf8) {
      print("📤 Request JSON:\n\(jsonString)")
    }
    
    request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: .fragmentsAllowed)
    
    let (data, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse else {
      throw PostServiceError.serverError(statusCode: 500)
    }
    
    // ✅ Debugging: Print API Response
    if let responseString = String(data: data, encoding: .utf8) {
      print("📥 API Response Body: \(responseString)")
    }
    
    switch httpResponse.statusCode {
    case 200, 201:
      print("✅ Comment successfully posted for postID: \(postID)")
    case 400:
      print("❌ Error: Invalid userSecret (400)")
      throw PostServiceError.unauthorized
    case 500:
      print("❌ Server error (500) - Check API logs")
      throw PostServiceError.serverError(statusCode: 500)
    default:
      print("❌ Unexpected error: \(httpResponse.statusCode)")
      throw PostServiceError.serverError(statusCode: httpResponse.statusCode)
    }
  }
  
  // MARK: - ✅ 6. DELETE COMMENT
  func deleteComment(commentID: Int) async throws {
    guard let userSecret = KeychainService.shared.get("userSecret") else {
      throw PostServiceError.unauthorized
    }
    
    guard let url = URL(string: "\(APIEndpoints.deleteComment)?userSecret=\(userSecret)&commentId=\(commentID)") else {
      throw PostServiceError.invalidURL
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"
    
    let (_, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
      throw PostServiceError.serverError(statusCode: 500)
    }
    
    print("✅ Comment \(commentID) deleted successfully")
  }
  
  func editPost(postID: Int, newTitle: String, newBody: String) async throws -> Post {
    guard let userSecret = User.current?.secret else {
      throw PostServiceError.missingUserSecret
    }
    
    let url = URL(string: "https://social-media-app.ryanplitt.com/editPost")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let requestBody: [String: Any] = [
      "userSecret": userSecret.uuidString,
      "postid": postID,
      "newTitle": newTitle,
      "newBody": newBody
    ]
    
    request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
      throw PostServiceError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 500)
    }
    
    let updatedPost = try JSONDecoder().decode(Post.self, from: data)
    return updatedPost
  }
}
