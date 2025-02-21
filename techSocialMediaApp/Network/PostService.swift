//
//  PostService.swift
//  techSocialMediaApp
//
//  Created by Wesley Keetch on 2/5/25.
//

import Foundation

class PostService {

  static let shared = PostService()

  enum PostServiceError: Error {
    case invalidURL
    case unauthorized
    case serverError
    case decodingError
  }
  // MARK: - ✅ 1. GET /posts (All Posts with Pagination)
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
        throw PostServiceError.serverError
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

          // ✅ Sorting posts by `createdDate` (newest first)
          let sortedPosts = posts.sorted(by: { $0.createdDate > $1.createdDate })
          print("✅ Successfully fetched \(sortedPosts.count) posts")

          return sortedPosts

        } catch let decodingError {
          print("❌ JSON Decoding Error: \(decodingError.localizedDescription)")
          throw PostServiceError.decodingError
        }

      case 400:
        print("❌ Bad Request: Missing userSecret")
        throw PostServiceError.unauthorized

      case 401, 403:
        print("❌ Unauthorized access: Invalid userSecret")
        throw PostServiceError.unauthorized

      default:
        print("❌ Server error: Status \(httpResponse.statusCode)")
        throw PostServiceError.serverError
      }
    } catch let error as URLError {
      print("❌ Network Error: \(error.localizedDescription)")
      throw PostServiceError.serverError
    } catch {
      print("❌ Unexpected Error: \(error.localizedDescription)")
      throw PostServiceError.serverError
    }
  }

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
          "postid": postID
      ]
      request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: .fragmentsAllowed)

      let (data, response) = try await URLSession.shared.data(for: request)
      guard let httpResponse = response as? HTTPURLResponse else {
          throw PostServiceError.serverError
      }

      print("📡 HTTP Status Code: \(httpResponse.statusCode)")

      switch httpResponse.statusCode {
      case 200, 201:
          let updatedPost = try JSONDecoder().decode(Post.self, from: data)
          print("✅ Like updated. Post \(postID) now has \(updatedPost.likes) likes.")
          return updatedPost
      case 400:
          print("❌ Bad Request: Invalid like request.")
          throw PostServiceError.serverError
      default:
          throw PostServiceError.serverError
      }
  }

  // MARK: - ✅ 2. POST /createPost (Create New Post)
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

    // Required body parameters
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
      throw PostServiceError.serverError
    }

    print("📡 HTTP Status Code: \(httpResponse.statusCode)")

    switch httpResponse.statusCode {
    case 200, 201:
      let createdPost = try JSONDecoder().decode(Post.self, from: data)
      print("✅ Post Created: \(createdPost.title)")
      return createdPost
    case 400:
      print("❌ Bad Request: Missing userSecret")
      throw PostServiceError.unauthorized
    default:
      throw PostServiceError.serverError
    }
  }

  // MARK: - ✅ 3. DELETE /post (Delete a Post by ID)
  func deletePost(postID: Int) async throws -> Bool {
    guard let userSecret = KeychainService.shared.get("userSecret") else {
      throw PostServiceError.unauthorized
    }

    guard let url = URL(string: "\(APIEndpoints.deletePost(postID: postID))?userSecret=\(userSecret)") else {
      throw PostServiceError.invalidURL
    }

    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let (_, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse else {
      throw PostServiceError.serverError
    }

    switch httpResponse.statusCode {
    case 200:
      print("✅ Post Deleted Successfully")
      return true
    case 400:
      print("❌ Bad Request: Missing or invalid userSecret")
      throw PostServiceError.unauthorized
    default:
      print("❌ Server error with status: \(httpResponse.statusCode)")
      throw PostServiceError.serverError
    }
  }
}
