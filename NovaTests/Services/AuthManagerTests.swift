import Foundation
import Testing
@testable import Nova

@Suite("AuthManager", .serialized)
struct AuthManagerTests {
    let keychain = KeychainService(service: "com.nova.auth.tests")

    init() {
        // Clean state
        try? keychain.delete(key: "access_token")
        try? keychain.delete(key: "refresh_token")
    }

    @Test func initiallyNotAuthenticated() {
        let manager = AuthManager(keychain: keychain)
        #expect(manager.isAuthenticated == false)
        #expect(manager.accessToken == nil)
    }

    @Test func storeTokensSetsAuthenticated() throws {
        let manager = AuthManager(keychain: keychain)
        try manager.storeTokens(
            accessToken: "access-123",
            refreshToken: "refresh-456"
        )
        #expect(manager.isAuthenticated == true)
        #expect(manager.accessToken == "access-123")
    }

    @Test func logoutClearsTokens() throws {
        let manager = AuthManager(keychain: keychain)
        try manager.storeTokens(accessToken: "a", refreshToken: "r")
        #expect(manager.isAuthenticated == true)

        try manager.logout()
        #expect(manager.isAuthenticated == false)
        #expect(manager.accessToken == nil)
    }

    @Test func restoresTokensFromKeychain() throws {
        // Store tokens directly in keychain
        try keychain.save(key: "access_token", value: "saved-access")
        try keychain.save(key: "refresh_token", value: "saved-refresh")

        // Create new manager — should load from keychain
        let manager = AuthManager(keychain: keychain)
        #expect(manager.isAuthenticated == true)
        #expect(manager.accessToken == "saved-access")
    }
}
