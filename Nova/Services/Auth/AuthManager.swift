import Foundation

@Observable
final class AuthManager {
    private(set) var isAuthenticated = false
    private(set) var accessToken: String?

    private let keychain: KeychainService
    private static let accessTokenKey = "access_token"
    private static let refreshTokenKey = "refresh_token"

    init(keychain: KeychainService = KeychainService()) {
        self.keychain = keychain
        loadTokens()
    }

    func storeTokens(accessToken: String, refreshToken: String) throws {
        try keychain.save(key: Self.accessTokenKey, value: accessToken)
        try keychain.save(key: Self.refreshTokenKey, value: refreshToken)
        self.accessToken = accessToken
        self.isAuthenticated = true
    }

    func logout() throws {
        try keychain.delete(key: Self.accessTokenKey)
        try keychain.delete(key: Self.refreshTokenKey)
        self.accessToken = nil
        self.isAuthenticated = false
    }

    private func loadTokens() {
        guard let token = try? keychain.retrieve(key: Self.accessTokenKey),
              (try? keychain.retrieve(key: Self.refreshTokenKey)) != nil else {
            return
        }
        self.accessToken = token
        self.isAuthenticated = true
    }
}
