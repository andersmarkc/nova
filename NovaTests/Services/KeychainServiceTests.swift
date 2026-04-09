import Foundation
import Testing
@testable import Nova

@Suite("KeychainService", .serialized)
struct KeychainServiceTests {
    let keychain = KeychainService(service: "com.nova.tests")

    init() {
        // Clean up before each test suite run
        try? keychain.delete(key: "test_token")
    }

    @Test func saveAndRetrieveToken() throws {
        try keychain.save(key: "test_token", value: "my-jwt-123")
        let retrieved = try keychain.retrieve(key: "test_token")
        #expect(retrieved == "my-jwt-123")
    }

    @Test func retrieveReturnsNilWhenMissing() throws {
        let result = try keychain.retrieve(key: "nonexistent_key_abc")
        #expect(result == nil)
    }

    @Test func deleteRemovesToken() throws {
        try keychain.save(key: "test_token", value: "to-be-deleted")
        try keychain.delete(key: "test_token")
        let result = try keychain.retrieve(key: "test_token")
        #expect(result == nil)
    }

    @Test func saveOverwritesExistingValue() throws {
        try keychain.save(key: "test_token", value: "first-value")
        try keychain.save(key: "test_token", value: "second-value")
        let result = try keychain.retrieve(key: "test_token")
        #expect(result == "second-value")
    }
}
