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
  
  // ✅ Use the app's bundle ID for Keychain namespace
  private let keychain: Keychain
  
  private init() {
    let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.default.techSocialMediaApp"
    print("ℹ️ Using Keychain service for bundle: \(bundleIdentifier)")
    
    keychain = Keychain(service: bundleIdentifier)
      .accessibility(.whenUnlocked, authenticationPolicy: .userPresence) // ✅ Secure Accessibility
      .synchronizable(false) // ✅ No iCloud sync
  }
  
  // MARK: - ✅ Save to Keychain
  func save(_ value: String, forKey key: String) {
    do {
      try keychain.set(value, key: key)
      print("✅ Successfully saved \(key) to Keychain")
    } catch let error {
      print("❌ Error saving \(key) to Keychain: \(error.localizedDescription)")
    }
  }
  
  // MARK: - ✅ Retrieve from Keychain
  func get(_ key: String) -> String? {
    do {
      if let value = try keychain.get(key) {
        print("📡 Retrieved \(key) from Keychain: \(value)")
        return value
      } else {
        print("⚠️ No value found for \(key) in Keychain")
        return nil
      }
    } catch let error {
      print("❌ Error retrieving \(key) from Keychain: \(error.localizedDescription)")
      return nil
    }
  }
  
  // MARK: - 🗑 Delete from Keychain
  func delete(_ key: String) {
    do {
      try keychain.remove(key)
      print("🗑 Successfully deleted \(key) from Keychain")
    } catch let error {
      print("❌ Error deleting \(key) from Keychain: \(error.localizedDescription)")
    }
  }
  
  // MARK: - 🧪 Test Keychain (For Debugging)
  func testKeychain() {
    save("testValue", forKey: "testKey")
    _ = get("testKey")
    delete("testKey")
  }
}
