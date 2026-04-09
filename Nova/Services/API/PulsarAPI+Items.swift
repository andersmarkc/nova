import Foundation

extension PulsarAPI {
    func itemVariants(itemId: Int, token: String) async throws -> ItemVariantsResponse {
        let endpoint = APIEndpoint.get("\(APIConfiguration.apiVersion)/items/\(itemId)/variants")
        return try await client.request(endpoint, token: token)
    }
}
