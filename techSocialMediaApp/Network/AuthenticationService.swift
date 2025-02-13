//
//  AuthenticationController.swift
//  techSocialMediaApp
//
//  Created by Brayden Lemke on 10/25/22.
//

import Foundation

class AuthenticationService {
  enum AuthError: Error, LocalizedError {
    case couldNotSignIn
    case invalidResponse
    case decodingError
  }

  /**
   Will make a request to authenticate the users credentials. If successful the User.current object will hold the signed in user.

   - Throws: If the user does not exist or if the API.url is invalid
   - Returns: A boolean depending on whether or not the operation was successful
   */
  func signIn(email: String, password: String) async throws -> Bool {
    // Initialize our session and request
    let session = URLSession.shared
    guard let url = URL(string: APIEndpoints.signIn) else {
      throw AuthError.invalidResponse
    }

    var request = URLRequest(url: url) // Uses updated API URL
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    // Put the credentials in JSON format
    let credentials: [String: Any] = ["email": email, "password": password]
    request.httpBody = try JSONSerialization.data(withJSONObject: credentials, options: .prettyPrinted)

    // Make the request
    let (data, response) = try await session.data(for: request)

    // Ensure we had a valid HTTP response
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
      throw AuthError.couldNotSignIn
    }

    // Decode response data into User struct
    let decoder = JSONDecoder()
    do {
      let user = try decoder.decode(User.self, from: data)

      // Securely store user credentials in Keychain instead of using User.current
      KeychainService.shared.save(user.secret.uuidString, forKey: "userSecret")
      KeychainService.shared.save(user.userUUID.uuidString, forKey: "userUUID")

      // Store non-sensitive user info in UserDefaults
      UserDefaults.standard.set(user.userName, forKey: "userName")
      UserDefaults.standard.set(user.firstName, forKey: "firstName")
      UserDefaults.standard.set(user.lastName, forKey: "lastName")

      return true
    } catch {
      throw AuthError.decodingError
    }
  }

  /**
   Logs out the user by removing stored credentials.
   */
  func logout() {
    KeychainService.shared.delete("userSecret")
    KeychainService.shared.delete("userUUID")
    UserDefaults.standard.removeObject(forKey: "userName")
    UserDefaults.standard.removeObject(forKey: "firstName")
    UserDefaults.standard.removeObject(forKey: "lastName")
  }
}
