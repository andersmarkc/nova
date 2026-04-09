import Foundation

extension PulsarAPI {
    func getDevToken(email: String) async throws -> AuthTokenResponse {
        let endpoint = APIEndpoint.post(
            "\(APIConfiguration.apiVersion)/auth/dev_token",
            body: ["email": email],
            requiresAuth: false
        )
        let response: APIDataResponse<AuthTokenResponse> = try await client.request(endpoint)
        return response.data
    }
}
