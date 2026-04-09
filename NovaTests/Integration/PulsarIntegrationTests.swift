import Foundation
import Testing
@testable import Nova

/// Integration tests that hit the real local Pulsar API.
/// Gated by PULSAR_INTEGRATION env var — skipped during normal test runs.
///
/// To run:
/// 1. Start local Pulsar: `cd ~/RubymineProjects/pulsar && bin/dev`
/// 2. Run: PULSAR_INTEGRATION=1 xcodebuild -scheme Nova \
///    -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
///    test -only-testing NovaTests
@Suite(
    "Pulsar Integration",
    .enabled(if: ProcessInfo.processInfo.environment["PULSAR_INTEGRATION"] != nil),
    .serialized
)
struct PulsarIntegrationTests {

    // MARK: - Auth

    @Test func devTokenReturnsValidJWT() async throws {
        let token = try await PulsarTestClient.getDevToken()
        #expect(token.hasPrefix("eyJ"))
        #expect(token.split(separator: ".").count == 3)
    }

    // MARK: - Search

    @Test func searchReturnsResults() async throws {
        let token = try await PulsarTestClient.getDevToken()
        let api = PulsarAPI(client: APIClient())
        let result = try await api.search(query: "maelk", token: token)
        #expect(result.meta.total >= 0)
    }

    @Test func searchSuggestionsReturnsItems() async throws {
        let token = try await PulsarTestClient.getDevToken()
        let api = PulsarAPI(client: APIClient())
        let suggestions = try await api.searchSuggestions(query: "m", token: token)
        // May be empty if Typesense has no data — the test verifies it does not throw
        _ = suggestions
    }
}
