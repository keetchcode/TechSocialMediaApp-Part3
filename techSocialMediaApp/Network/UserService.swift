//
//  UserService.swift
//  techSocialMediaApp
//
//  Created by Wesley Keetch on 2/5/25.
//

import Foundation

class UserService {

  /**
   Fetches the signed-in user's profile.
   - Returns: A User object or throws an error.
   */

  func fetchUserProfile() async throws -> User {
    guard let userUUID = KeychainService.shared.get("userUUID"),
          let userSecret = KeychainService.shared.get("userSecret") else {
      print("❌ Missing userUUID or userSecret. Cannot fetch profile.")
      throw URLError(.userAuthenticationRequired)
    }

    print("📡 Fetching profile for userUUID: \(userUUID)")

    guard let url = URL(string: "https://social-media-app.ryanplitt.com/userProfile?userUUID=\(userUUID)&userSecret=\(userSecret)") else {
      throw URLError(.badURL)
    }

    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
      throw URLError(.badServerResponse)
    }

    let user = try JSONDecoder().decode(User.self, from: data)
    print("✅ Successfully fetched user profile: \(user)")

    return user
  }

  /**
   Updates the signed-in user's profile.
   - Returns: A boolean indicating success or failure.
   */
  
  func updateUserProfile(userName: String, bio: String, techInterests: String) async throws -> Bool {
    guard let url = URL(string: APIEndpoints.updateProfile) else {
      throw URLError(.badURL)
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = APIEndpoints.getAuthHeaders()

    let profileDetails = [
      "userName": userName,
      "bio": bio,
      "techInterests": techInterests
    ]

    request.httpBody = try JSONSerialization.data(withJSONObject: profileDetails, options: .prettyPrinted)

    let (_, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
      throw URLError(.badServerResponse)
    }

    return true
  }
}

