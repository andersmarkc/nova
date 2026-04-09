import Foundation

final class MockURLProtocol: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (Data, HTTPURLResponse))?

    override static func canInit(with request: URLRequest) -> Bool {
        // Only handle requests from mock sessions (ephemeral config)
        true
    }

    override static func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = Self.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        do {
            let (data, response) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}

    static func reset() {
        requestHandler = nil
    }
}

/// Helper to make a mock response from a fixture file
enum MockResponse {
    static func fixture(
        _ name: String,
        statusCode: Int = 200,
        headers: [String: String]? = nil
    ) -> (URLRequest) throws -> (Data, HTTPURLResponse) {
        { request in
            let data = try FixtureLoader.load(name)
            let response = HTTPURLResponse(
                // swiftlint:disable:next force_unwrapping
                url: request.url!,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: headers
            )!  // swiftlint:disable:this force_unwrapping
            return (data, response)
        }
    }

    static func json(
        _ jsonString: String,
        statusCode: Int = 200,
        headers: [String: String]? = nil
    ) -> (URLRequest) throws -> (Data, HTTPURLResponse) {
        { request in
            let data = jsonString.data(using: .utf8) ?? Data()
            let response = HTTPURLResponse(
                // swiftlint:disable:next force_unwrapping
                url: request.url!,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: headers
            )!  // swiftlint:disable:this force_unwrapping
            return (data, response)
        }
    }
}
