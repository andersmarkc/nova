import Foundation
import Testing
@testable import Nova

@Suite("APIError")
struct APIErrorTests {

    @Test func unauthorizedError() {
        let error = APIError.unauthorized
        #expect(error == .unauthorized)
        #expect(error.errorDescription != nil)
    }

    @Test func notFoundError() {
        let error = APIError.notFound
        #expect(error == .notFound)
    }

    @Test func rateLimitedError() {
        let error = APIError.rateLimited(retryAfter: 60)
        if case .rateLimited(let retryAfter) = error {
            #expect(retryAfter == 60)
        } else {
            Issue.record("Expected rateLimited error")
        }
    }

    @Test func validationError() {
        let error = APIError.validationError(["email is required"])
        if case .validationError(let messages) = error {
            #expect(messages == ["email is required"])
        } else {
            Issue.record("Expected validationError")
        }
    }

    @Test func serverError() {
        let error = APIError.serverError(500)
        if case .serverError(let code) = error {
            #expect(code == 500)
        } else {
            Issue.record("Expected serverError")
        }
    }

    @Test func networkError() {
        let urlError = URLError(.notConnectedToInternet)
        let error = APIError.networkError(urlError)
        if case .networkError(let inner) = error {
            #expect(inner.code == .notConnectedToInternet)
        } else {
            Issue.record("Expected networkError")
        }
    }

    @Test func decodingError() {
        let error = APIError.decodingError("missing key")
        if case .decodingError(let message) = error {
            #expect(message == "missing key")
        } else {
            Issue.record("Expected decodingError")
        }
    }

    @Test func allErrorsHaveDescriptions() {
        let errors: [APIError] = [
            .unauthorized,
            .notFound,
            .rateLimited(retryAfter: 30),
            .validationError(["test"]),
            .serverError(502),
            .networkError(URLError(.timedOut)),
            .decodingError("bad json"),
            .unknown("something")
        ]
        for error in errors {
            #expect(error.errorDescription != nil, "Missing description for \(error)")
        }
    }
}
