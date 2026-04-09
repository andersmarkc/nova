import Foundation
import Testing
@testable import Nova

@Suite("APIEndpoint")
struct APIEndpointTests {

    @Test func getEndpointURL() {
        let endpoint = APIEndpoint.get("/api/v1/search")
        #expect(endpoint.url.absoluteString.hasSuffix("/api/v1/search"))
        #expect(endpoint.method == .get)
    }

    @Test func postEndpointURL() {
        let endpoint = APIEndpoint.post("/api/v1/auth/dev_token", body: ["email": "test@test.com"])
        #expect(endpoint.method == .post)
        #expect(endpoint.body != nil)
    }

    @Test func queryParameters() {
        let endpoint = APIEndpoint.get("/api/v1/search", queryItems: [
            URLQueryItem(name: "q", value: "maelk"),
            URLQueryItem(name: "page", value: "1")
        ])
        let urlString = endpoint.url.absoluteString
        #expect(urlString.contains("q=maelk"))
        #expect(urlString.contains("page=1"))
    }

    @Test func urlRequestIncludesContentType() {
        let endpoint = APIEndpoint.get("/api/v1/search")
        let request = endpoint.urlRequest(token: nil)
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
    }

    @Test func urlRequestIncludesAuthToken() {
        let endpoint = APIEndpoint.get("/api/v1/search", requiresAuth: true)
        let request = endpoint.urlRequest(token: "my-jwt-token")
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer my-jwt-token")
    }

    @Test func urlRequestOmitsAuthWhenNotRequired() {
        let endpoint = APIEndpoint.get("/api/v1/search", requiresAuth: false)
        let request = endpoint.urlRequest(token: "my-jwt-token")
        #expect(request.value(forHTTPHeaderField: "Authorization") == nil)
    }

    @Test func urlRequestHTTPMethod() {
        let getEndpoint = APIEndpoint.get("/test")
        #expect(getEndpoint.urlRequest(token: nil).httpMethod == "GET")

        let postEndpoint = APIEndpoint.post("/test")
        #expect(postEndpoint.urlRequest(token: nil).httpMethod == "POST")

        let patchEndpoint = APIEndpoint.patch("/test")
        #expect(patchEndpoint.urlRequest(token: nil).httpMethod == "PATCH")

        let deleteEndpoint = APIEndpoint.delete("/test")
        #expect(deleteEndpoint.urlRequest(token: nil).httpMethod == "DELETE")
    }

    @Test func baseURLComesFromConfiguration() {
        let endpoint = APIEndpoint.get("/api/v1/search")
        let expectedBase = APIConfiguration.baseURL.absoluteString
        #expect(endpoint.url.absoluteString.hasPrefix(expectedBase))
    }
}
