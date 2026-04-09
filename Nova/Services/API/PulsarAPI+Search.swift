import Foundation

extension PulsarAPI {
    func search(
        query: String,
        shopIds: [Int]? = nil,
        onSale: Bool = false,
        sort: String? = nil,
        page: Int = 1,
        perPage: Int = 20,
        token: String
    ) async throws -> SearchResult {
        var queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]
        if let shopIds, !shopIds.isEmpty {
            queryItems.append(URLQueryItem(name: "shop_ids", value: shopIds.map(String.init).joined(separator: ",")))
        }
        if onSale {
            queryItems.append(URLQueryItem(name: "on_sale", value: "1"))
        }
        if let sort {
            queryItems.append(URLQueryItem(name: "sort", value: sort))
        }

        let endpoint = APIEndpoint.get(
            "\(APIConfiguration.apiVersion)/search",
            queryItems: queryItems
        )
        return try await client.request(endpoint, token: token)
    }

    func searchSuggestions(query: String, token: String) async throws -> [SearchSuggestion] {
        let endpoint = APIEndpoint.get(
            "\(APIConfiguration.apiVersion)/search/suggestions",
            queryItems: [URLQueryItem(name: "q", value: query)]
        )
        let response: APIDataResponse<[SearchSuggestion]> = try await client.request(endpoint, token: token)
        return response.data
    }
}
