import Foundation

nonisolated final class APIClient: Sendable {
    static let shared = APIClient()

    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }

    func request<T: Decodable & Sendable>(
        _ endpoint: APIEndpoint,
        token: String? = nil
    ) async throws -> T {
        let urlRequest = endpoint.urlRequest(token: token)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch let urlError as URLError {
            throw APIError.networkError(urlError)
        } catch {
            throw APIError.unknown(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown("Not an HTTP response")
        }

        try mapStatusCode(httpResponse, data: data)

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error.localizedDescription)
        }
    }

    func requestVoid(_ endpoint: APIEndpoint, token: String? = nil) async throws {
        let urlRequest = endpoint.urlRequest(token: token)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch let urlError as URLError {
            throw APIError.networkError(urlError)
        } catch {
            throw APIError.unknown(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown("Not an HTTP response")
        }

        try mapStatusCode(httpResponse, data: data)
    }

    private func mapStatusCode(_ response: HTTPURLResponse, data: Data) throws {
        switch response.statusCode {
        case 200...299:
            return
        case 401:
            throw APIError.unauthorized
        case 404:
            throw APIError.notFound
        case 422:
            throw APIError.validationError(parseErrors(data))
        case 429:
            let retry = Int(response.value(forHTTPHeaderField: "Retry-After") ?? "60") ?? 60
            throw APIError.rateLimited(retryAfter: retry)
        case 500...599:
            throw APIError.serverError(response.statusCode)
        default:
            throw APIError.unknown("HTTP \(response.statusCode)")
        }
    }

    private func parseErrors(_ data: Data) -> [String] {
        (try? JSONDecoder().decode(PulsarErrorBody.self, from: data))?.errors ?? []
    }
}

private struct PulsarErrorBody: Decodable {
    let errors: [String]
}
