//
//  PostService.swift
//  techSocialMediaApp
//
//  Created by Wesley Keetch on 2/5/25.
//

import Foundation

class PostService {
  /**
   Fetches all posts.
   - Returns: An array of Post objects or throws an error.
   */
  func fetchPosts(pageNumber: Int = 0) async throws -> [Post] {
    guard let url = URL(string: "\(APIEndpoints.posts)?pageNumber=\(pageNumber)") else {
      throw URLError(.badURL)
    }
    
    var request = URLRequest(url: url)
    request.allHTTPHeaderFields = APIEndpoints.getAuthHeaders()
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
      throw URLError(.badServerResponse)
    }
    
    return try JSONDecoder().decode([Post].self, from: data)
  }
  
  /**
   Creates a new post.
   - Returns: The created Post object or throws an error.
   */
  func createPost(title: String, body: String) async throws -> Post {
    guard let url = URL(string: APIEndpoints.createPost) else {
      throw URLError(.badURL)
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = APIEndpoints.getAuthHeaders()
    
    let postDetails = ["title": title, "body": body]
    request.httpBody = try JSONSerialization.data(withJSONObject: postDetails, options: .prettyPrinted)
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
      throw URLError(.badServerResponse)
    }
    
    return try JSONDecoder().decode(Post.self, from: data)
  }
  
  /**
   Deletes a post by its post ID.
   - Returns: A boolean indicating success or failure.
   */
  func deletePost(postID: Int) async throws -> Bool {
    guard let url = URL(string: APIEndpoints.deletePost(postID: postID)) else {
      throw URLError(.badURL)
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"
    request.allHTTPHeaderFields = APIEndpoints.getAuthHeaders()
    
    let (_, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
      throw URLError(.badServerResponse)
    }
    
    return true
  }
}
