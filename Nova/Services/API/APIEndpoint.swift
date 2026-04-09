import Foundation

nonisolated struct APIEndpoint: Sendable {
    let path: String
    let method: HTTPMethod
    let queryItems: [URLQueryItem]
    let body: Data?
    let requiresAuth: Bool

    enum HTTPMethod: String, Sendable {
        case get = "GET"
        case post = "POST"
        case patch = "PATCH"
        case delete = "DELETE"
    }

    var url: URL {
        var components = URLComponents(
            url: APIConfiguration.baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        )
        if !queryItems.isEmpty {
            components?.queryItems = queryItems
        }
        return components?.url ?? APIConfiguration.baseURL
    }

    func urlRequest(token: String?) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if requiresAuth, let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = body
        return request
    }
}

extension APIEndpoint {
    static func get(
        _ path: String,
        queryItems: [URLQueryItem] = [],
        requiresAuth: Bool = true
    ) -> APIEndpoint {
        APIEndpoint(path: path, method: .get, queryItems: queryItems, body: nil, requiresAuth: requiresAuth)
    }

    static func post(
        _ path: String,
        body: [String: Any]? = nil,
        requiresAuth: Bool = true
    ) -> APIEndpoint {
        let bodyData = body.flatMap { try? JSONSerialization.data(withJSONObject: $0) }
        return APIEndpoint(path: path, method: .post, queryItems: [], body: bodyData, requiresAuth: requiresAuth)
    }

    static func patch(
        _ path: String,
        body: [String: Any]? = nil,
        requiresAuth: Bool = true
    ) -> APIEndpoint {
        let bodyData = body.flatMap { try? JSONSerialization.data(withJSONObject: $0) }
        return APIEndpoint(path: path, method: .patch, queryItems: [], body: bodyData, requiresAuth: requiresAuth)
    }

    static func delete(
        _ path: String,
        requiresAuth: Bool = true
    ) -> APIEndpoint {
        APIEndpoint(path: path, method: .delete, queryItems: [], body: nil, requiresAuth: requiresAuth)
    }
}
