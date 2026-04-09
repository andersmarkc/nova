import Foundation

nonisolated enum APIError: Error, Sendable, Equatable, LocalizedError {
    case unauthorized
    case notFound
    case rateLimited(retryAfter: Int)
    case validationError([String])
    case serverError(Int)
    case networkError(URLError)
    case decodingError(String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            String(localized: "error.unauthorized", defaultValue: "Din session er udløbet. Log ind igen.")
        case .notFound:
            String(localized: "error.notFound", defaultValue: "Kunne ikke finde det du søgte.")
        case .rateLimited:
            String(localized: "error.rateLimited", defaultValue: "For mange forespørgsler. Prøv igen om lidt.")
        case .validationError(let messages):
            messages.joined(separator: ", ")
        case .serverError:
            String(localized: "error.serverError", defaultValue: "Serverfejl. Prøv igen senere.")
        case .networkError:
            String(localized: "error.networkError", defaultValue: "Ingen internetforbindelse.")
        case .decodingError:
            String(localized: "error.decodingError", defaultValue: "Uventet svar fra serveren.")
        case .unknown(let message):
            message
        }
    }
}
