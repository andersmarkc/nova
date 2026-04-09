import Foundation

nonisolated final class PulsarAPI: Sendable {
    static let shared = PulsarAPI()

    let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }
}
