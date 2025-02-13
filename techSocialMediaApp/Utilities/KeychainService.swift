//
//  KeychainService.swift
//  techSocialMediaApp
//
//  Created by Wesley Keetch on 2/5/25.
//

import Foundation
import KeychainAccess

class KeychainService {
  static let shared = KeychainService() // Singleton instance
  private let keychain = Keychain(service: "com.wesley.techSocialMediaApp") // Replace with your app’s bundle ID

  // Save a value to Keychain
  func save(_ value: String, forKey key: String) {
    do {
      try keychain.set(value, key: key)
    } catch {
      print("Error saving to Keychain: \(error)")
    }
  }

  // Retrieve a value from Keychain
  func get(_ key: String) -> String? {
    do {
      return try keychain.get(key)
    } catch {
      print("Error retrieving from Keychain: \(error)")
      return nil
    }
  }

  // Delete a value from Keychain
  func delete(_ key: String) {
    do {
      try keychain.remove(key)
    } catch {
      print("Error deleting from Keychain: \(error)")
    }
  }
}
