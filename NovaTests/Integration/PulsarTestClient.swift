import Foundation
@testable import Nova

/// Helper for integration tests that hit the real Pulsar API.
/// Requires local Pulsar running: `cd ~/RubymineProjects/billigst_apps/pulsar && bin/dev`
/// Run with: `PULSAR_INTEGRATION=1 xcodebuild test ...`
enum PulsarTestClient {
    static let baseURL = APIEnvironment.local.baseURL
    static let testEmail = "nova-test@bowsersoftware.com"

    static func getDevToken() async throws -> String {
        let api = PulsarAPI(client: APIClient())
        let response = try await api.getDevToken(email: testEmail)
        return response.accessToken
    }
}
