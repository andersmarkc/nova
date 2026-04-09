import Foundation

nonisolated enum APIEnvironment: Sendable {
    case production
    case local

    var baseURL: URL {
        switch self {
        case .production:
            // swiftlint:disable:next force_unwrapping
            URL(string: "https://pulsar.bowsersoftware.com")!
        case .local:
            // swiftlint:disable:next force_unwrapping
            URL(string: "http://localhost:3000")!
        }
    }
}

nonisolated enum APIConfiguration {
    #if DEBUG
    static let environment: APIEnvironment = .production
    #else
    static let environment: APIEnvironment = .production
    #endif

    static var baseURL: URL { environment.baseURL }
    static let apiVersion = "/api/v1"
}
