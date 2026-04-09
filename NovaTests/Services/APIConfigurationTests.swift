import Foundation
import Testing
@testable import Nova

@Suite("APIConfiguration")
struct APIConfigurationTests {

    @Test func baseURLIsValid() {
        let url = APIConfiguration.baseURL
        #expect(url.scheme == "https" || url.scheme == "http")
        #expect(url.host != nil)
    }

    @Test func productionEnvironmentURL() {
        let url = APIEnvironment.production.baseURL
        #expect(url.absoluteString == "https://pulsar.bowsersoftware.com")
    }

    @Test func localEnvironmentURL() {
        let url = APIEnvironment.local.baseURL
        #expect(url.absoluteString == "http://localhost:3000")
    }

    @Test func apiVersionPath() {
        let url = APIConfiguration.baseURL.appendingPathComponent("/api/v1/search")
        #expect(url.absoluteString.contains("/api/v1/search"))
    }
}
