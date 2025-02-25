//
//  AuthenticationController.swift
//  techSocialMediaApp
//
//  Created by Brayden Lemke on 10/25/22.
//

import Foundation

class AuthenticationService {

  static let shared = AuthenticationService()

  enum AuthError: Error, LocalizedError {
    case couldNotSignIn
    case invalidResponse
    case decodingError
  }

  /**
   Authenticates the user with email & password.
   - Throws: If the credentials are incorrect or there’s an API error.
   - Returns: A boolean indicating if sign-in was successful.
   */
  func signIn(email: String, password: String) async throws -> Bool {
    let session = URLSession.shared
    guard let url = URL(string: APIEndpoints.signIn) else {
      throw AuthError.invalidResponse
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let credentials: [String: Any] = ["email": email, "password": password]
    request.httpBody = try JSONSerialization.data(withJSONObject: credentials, options: .prettyPrinted)

    let (data, response) = try await session.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
      throw AuthError.couldNotSignIn
    }

    let decoder = JSONDecoder()
    do {
      let user = try decoder.decode(User.self, from: data)

      // ✅ Store credentials securely in Keychain
      KeychainService.shared.save(user.userUUID.uuidString, forKey: "userUUID")
      KeychainService.shared.save(user.secret.uuidString, forKey: "userSecret")

      // ✅ Store non-sensitive user profile in UserDefaults
      UserDefaults.standard.set(user.userName, forKey: "userName")
      UserDefaults.standard.set(user.firstName, forKey: "firstName")
      UserDefaults.standard.set(user.lastName, forKey: "lastName")

      print("✅ User successfully signed in: \(user.userName)")
      return true
    } catch {
      throw AuthError.decodingError
    }
  }

  /**
   Logs out the user by removing stored credentials.
   */

  func logout() {
    print("🚪 Logging out user...")

    // ✅ Clear credentials from Keychain
    KeychainService.shared.delete("userSecret")
    KeychainService.shared.delete("userUUID")

    // ✅ Clear user info from UserDefaults
    UserDefaults.standard.removeObject(forKey: "userName")
    UserDefaults.standard.removeObject(forKey: "firstName")
    UserDefaults.standard.removeObject(forKey: "lastName")

    print("🗑 User credentials cleared")
  }
}
