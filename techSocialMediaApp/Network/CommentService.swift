//
//  CommentService.swift
//  techSocialMediaApp
//
//  Created by Wesley Keetch on 2/5/25.
//

import Foundation

class CommentService {
  /**
   Fetches comments for a given post.
   - Returns: An array of Comment objects or throws an error.
   */
  func fetchComments(for postID: Int, pageNumber: Int = 0) async throws -> [Comment] {
    guard let url = URL(string: "\(APIEndpoints.getComments)?postid=\(postID)&pageNumber=\(pageNumber)") else {
      throw URLError(.badURL)
    }
    
    var request = URLRequest(url: url)
    request.allHTTPHeaderFields = APIEndpoints.getAuthHeaders()
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
      throw URLError(.badServerResponse)
    }
    
    return try JSONDecoder().decode([Comment].self, from: data)
  }
  
  /**
   Creates a new comment on a given post.
   - Returns: The created Comment object or throws an error.
   */
  func createComment(for postID: Int, commentBody: String) async throws -> Comment {
    guard let url = URL(string: APIEndpoints.createComment) else {
      throw URLError(.badURL)
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = APIEndpoints.getAuthHeaders()
    
    let commentDetails = ["commentBody": commentBody, "postid": postID] as [String : Any]
    request.httpBody = try JSONSerialization.data(withJSONObject: commentDetails, options: .prettyPrinted)
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
      throw URLError(.badServerResponse)
    }
    
    return try JSONDecoder().decode(Comment.self, from: data)
  }
}

