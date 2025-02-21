//
//  CommentService.swift
//  techSocialMediaApp
//
//  Created by Wesley Keetch on 2/5/25.
//

import Foundation

class CommentService {
  static let shared = CommentService()

  enum CommentServiceError: Error {
    case invalidURL, serverError, decodingError, unauthorized, badRequest, missingAuth
  }

  /**
   Fetches comments for a given post from the API.
   - Parameters:
   - postID: The ID of the post to fetch comments for.
   - pageNumber: Optional page number for pagination.
   - Returns: An array of Comment objects.
   */

  func fetchComments(for postID: Int, pageNumber: Int = 0) async throws -> [Comment] {
    guard let userSecret = KeychainService.shared.get("userSecret") else {
      throw CommentServiceError.missingAuth
    }

    guard let url = URL(string: "\(APIEndpoints.getComments)?postid=\(postID)&userSecret=\(userSecret)&pageNumber=\(pageNumber)") else {
      throw URLError(.badURL)
    }

    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw URLError(.badServerResponse)
    }

    print("📡 HTTP Status Code: \(httpResponse.statusCode)")

    if httpResponse.statusCode == 200 {
      return try JSONDecoder().decode([Comment].self, from: data)
    } else if httpResponse.statusCode == 400 {
      print("❌ Bad Request: Missing userSecret or postid")
      throw CommentServiceError.badRequest
    } else {
      throw URLError(.badServerResponse)
    }
  }

  /**
   Creates a new comment for a given post.
   - Parameters:
   - postID: The ID of the post to comment on.
   - commentBody: The body of the comment.
   - Returns: The created Comment object.
   */
  func createComment(for postID: Int, commentBody: String) async throws -> Comment {
    guard let url = URL(string: APIEndpoints.createComment) else {
      throw CommentServiceError.invalidURL
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    // ✅ Add Authentication Header
    guard let userSecret = KeychainService.shared.get("userSecret") else {
      throw CommentServiceError.unauthorized
    }
    request.setValue(userSecret, forHTTPHeaderField: "userSecret")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    // ✅ Add Request Body
    let commentDetails = ["commentBody": commentBody, "postid": postID] as [String: Any]
    request.httpBody = try JSONSerialization.data(withJSONObject: commentDetails, options: .prettyPrinted)

    // ✅ Execute Request
    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw CommentServiceError.serverError
    }

    print("📡 HTTP Status Code: \(httpResponse.statusCode)")

    switch httpResponse.statusCode {
    case 200:
      do {
        let comment = try JSONDecoder().decode(Comment.self, from: data)
        print("✅ Comment created successfully: \(comment.commentID)")
        return comment
      } catch {
        throw CommentServiceError.decodingError
      }
    case 400:
      print("❌ Bad Request: Missing userSecret or postid")
      throw CommentServiceError.unauthorized
    case 401, 403:
      print("❌ Unauthorized: Invalid credentials")
      throw CommentServiceError.unauthorized
    default:
      print("❌ Server error with status: \(httpResponse.statusCode)")
      throw CommentServiceError.serverError
    }
  }
}
