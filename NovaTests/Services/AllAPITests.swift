import Foundation
import Testing
@testable import Nova

/// All tests using MockURLProtocol must be in this single .serialized suite
/// because MockURLProtocol.requestHandler is process-wide shared state.
/// Swift Testing runs separate @Suite types in parallel — .serialized only
/// applies within one suite, not across suites.
@Suite("All API Tests", .serialized)
struct AllAPITests {

    // MARK: - APIClient Tests

    @Suite("APIClient")
    struct Client {
        let client = APIClient(session: .mock)

        @Test func decodesSuccessfulResponse() async throws {
            MockURLProtocol.requestHandler = MockResponse.json(
                "{\"name\": \"Test\", \"value\": 42}"
            )
            let endpoint = APIEndpoint.get("/api/v1/test", requiresAuth: false)
            let result: SimpleModel = try await client.request(endpoint)
            #expect(result.name == "Test")
            #expect(result.value == 42)
        }

        @Test func maps401ToUnauthorized() async {
            MockURLProtocol.requestHandler = MockResponse.json(
                "{\"errors\": [\"Unauthorized\"]}",
                statusCode: 401
            )
            let endpoint = APIEndpoint.get("/api/v1/test", requiresAuth: false)
            await #expect(throws: APIError.unauthorized) {
                let _: SimpleModel = try await client.request(endpoint)
            }
        }

        @Test func maps404ToNotFound() async {
            MockURLProtocol.requestHandler = MockResponse.json(
                "{\"errors\": [\"Not found\"]}",
                statusCode: 404
            )
            let endpoint = APIEndpoint.get("/api/v1/test", requiresAuth: false)
            await #expect(throws: APIError.notFound) {
                let _: SimpleModel = try await client.request(endpoint)
            }
        }

        @Test func maps429ToRateLimited() async {
            MockURLProtocol.requestHandler = MockResponse.json(
                "{}",
                statusCode: 429,
                headers: ["Retry-After": "30"]
            )
            let endpoint = APIEndpoint.get("/api/v1/test", requiresAuth: false)
            await #expect(throws: APIError.rateLimited(retryAfter: 30)) {
                let _: SimpleModel = try await client.request(endpoint)
            }
        }

        @Test func maps422ToValidationError() async {
            MockURLProtocol.requestHandler = MockResponse.json(
                "{\"errors\": [\"email is required\"]}",
                statusCode: 422
            )
            let endpoint = APIEndpoint.get("/api/v1/test", requiresAuth: false)
            await #expect(throws: APIError.validationError(["email is required"])) {
                let _: SimpleModel = try await client.request(endpoint)
            }
        }

        @Test func maps500ToServerError() async {
            MockURLProtocol.requestHandler = MockResponse.json("{}", statusCode: 500)
            let endpoint = APIEndpoint.get("/api/v1/test", requiresAuth: false)
            await #expect(throws: APIError.serverError(500)) {
                let _: SimpleModel = try await client.request(endpoint)
            }
        }

        @Test func mapsInvalidJSONToDecodingError() async {
            MockURLProtocol.requestHandler = MockResponse.json("not json")
            let endpoint = APIEndpoint.get("/api/v1/test", requiresAuth: false)
            do {
                let _: SimpleModel = try await client.request(endpoint)
                Issue.record("Expected decodingError")
            } catch {
                #expect(error is APIError)
            }
        }

        @Test func injectsAuthToken() async throws {
            MockURLProtocol.requestHandler = { request in
                #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer jwt-123")
                let data = Data("{\"name\":\"Auth\",\"value\":1}".utf8)
                // swiftlint:disable:next force_unwrapping
                let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (data, response)
            }
            let endpoint = APIEndpoint.get("/api/v1/test", requiresAuth: true)
            let _: SimpleModel = try await client.request(endpoint, token: "jwt-123")
        }

        @Test func decodesSnakeCaseKeys() async throws {
            MockURLProtocol.requestHandler = MockResponse.json(
                "{\"first_name\": \"Anders\", \"last_name\": \"Mark\"}"
            )
            let endpoint = APIEndpoint.get("/api/v1/test", requiresAuth: false)
            let result: SnakeModel = try await client.request(endpoint)
            #expect(result.firstName == "Anders")
        }
    }

    // MARK: - PulsarAPI Auth Tests

    @Suite("PulsarAPI+Auth")
    struct Auth {
        let api = PulsarAPI(client: APIClient(session: .mock))

        @Test func devTokenReturnsTokens() async throws {
            MockURLProtocol.requestHandler = MockResponse.fixture("dev_token_response")
            let result = try await api.getDevToken(email: "test@test.com")
            #expect(result.accessToken.hasPrefix("eyJ"))
            #expect(result.tokenType == "Bearer")
            #expect(result.expiresIn == 3600)
        }

        @Test func devTokenSendsEmail() async throws {
            MockURLProtocol.requestHandler = { request in
                let body = request.httpBody.flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Any] }
                #expect(body?["email"] as? String == "test@test.com")
                return try MockResponse.fixture("dev_token_response")(request)
            }
            _ = try await api.getDevToken(email: "test@test.com")
        }
    }

    // MARK: - PulsarAPI Search Tests

    @Suite("PulsarAPI+Search")
    struct Search {
        let api = PulsarAPI(client: APIClient(session: .mock))

        @Test func searchReturnsHits() async throws {
            MockURLProtocol.requestHandler = MockResponse.fixture("search_response")
            let result = try await api.search(query: "maelk", token: "t")
            #expect(result.data.hits.count == 2)
            #expect(result.meta.total == 2)
            #expect(result.data.hits[0].itemName == "Letmaelk")
        }

        @Test func searchIncludesQueryParams() async throws {
            MockURLProtocol.requestHandler = { request in
                let url = request.url?.absoluteString ?? ""
                #expect(url.contains("q=maelk"))
                #expect(url.contains("page=2"))
                #expect(url.contains("per_page=10"))
                return try MockResponse.fixture("search_response")(request)
            }
            _ = try await api.search(query: "maelk", page: 2, perPage: 10, token: "t")
        }

        @Test func suggestionsReturnsItems() async throws {
            MockURLProtocol.requestHandler = MockResponse.fixture("suggestions_response")
            let result = try await api.searchSuggestions(query: "mae", token: "t")
            #expect(result.count == 3)
            #expect(result[0].itemName == "Letmaelk")
        }
    }

    // MARK: - PulsarAPI Items Tests

    @Suite("PulsarAPI+Items")
    struct Items {
        let api = PulsarAPI(client: APIClient(session: .mock))

        @Test func itemVariantsReturnsData() async throws {
            MockURLProtocol.requestHandler = MockResponse.fixture("item_variants_response")
            let result = try await api.itemVariants(itemId: 42, token: "t")
            #expect(result.item.id == 42)
            #expect(result.item.name == "Letmaelk")
            #expect(result.variants.count == 1)
            #expect(result.variants[0].prices.count == 2)
        }

        @Test func pricesAreDecimal() async throws {
            MockURLProtocol.requestHandler = MockResponse.fixture("item_variants_response")
            let result = try await api.itemVariants(itemId: 42, token: "t")
            let price = result.variants[0].prices[0]
            #expect(price.amount == Decimal(string: "12.95"))
        }
    }
}

// MARK: - Test Models

nonisolated private struct SimpleModel: Decodable, Sendable {
    let name: String
    let value: Int
}

nonisolated private struct SnakeModel: Decodable, Sendable {
    let firstName: String
    let lastName: String
}
