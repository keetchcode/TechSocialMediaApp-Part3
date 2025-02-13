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
    guard let url = URL(string: APIEndpoints.userProfile) else {
      throw URLError(.badURL)
    }
    
    var request = URLRequest(url: url)
    request.allHTTPHeaderFields = APIEndpoints.getAuthHeaders()
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
      throw URLError(.badServerResponse)
    }
    
    return try JSONDecoder().decode(User.self, from: data)
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

