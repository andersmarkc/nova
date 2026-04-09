import Foundation
import Testing
@testable import Nova

@Suite("Model Decoding")
struct DecodingTests {
    let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    // MARK: - AuthTokenResponse

    @Test func decodesDevTokenResponse() throws {
        let data = try FixtureLoader.load("dev_token_response")
        let response = try decoder.decode(APIDataResponse<AuthTokenResponse>.self, from: data)
        #expect(response.data.accessToken.hasPrefix("eyJ"))
        #expect(response.data.refreshToken.hasPrefix("eyJ"))
        #expect(response.data.tokenType == "Bearer")
        #expect(response.data.expiresIn == 3600)
    }

    // MARK: - Search

    @Test func decodesSearchResponse() throws {
        let data = try FixtureLoader.load("search_response")
        let response = try decoder.decode(SearchResult.self, from: data)
        #expect(response.data.hits.count == 2)
        #expect(response.meta.total == 2)
        #expect(response.meta.query == "maelk")

        let firstHit = response.data.hits[0]
        #expect(firstHit.id == "1")
        #expect(firstHit.itemId == 42)
        #expect(firstHit.itemName == "Letmaelk")
        #expect(firstHit.brand == "Arla")
        #expect(firstHit.minPrice == 12.95)
        #expect(firstHit.onSale == false)
        #expect(firstHit.shopIds == [1, 3])
    }

    @Test func decodesSuggestionsResponse() throws {
        let data = try FixtureLoader.load("suggestions_response")
        let response = try decoder.decode(APIDataResponse<[SearchSuggestion]>.self, from: data)
        #expect(response.data.count == 3)
        #expect(response.data[0].itemId == 42)
        #expect(response.data[0].itemName == "Letmaelk")
    }

    // MARK: - Item Variants

    @Test func decodesItemVariantsResponse() throws {
        let data = try FixtureLoader.load("item_variants_response")
        let response = try decoder.decode(ItemVariantsResponse.self, from: data)
        #expect(response.item.id == 42)
        #expect(response.item.name == "Letmaelk")
        #expect(response.attributeDefinitions.count == 1)
        #expect(response.variants.count == 1)

        let variant = response.variants[0]
        #expect(variant.id == "pv_1")
        #expect(variant.brand == "Arla")
        #expect(variant.prices.count == 2)

        let nettoPrice = variant.prices[0]
        #expect(nettoPrice.shopId == 1)
        #expect(nettoPrice.shopName == "Netto")
        #expect(nettoPrice.amount == Decimal(string: "12.95"))
        #expect(nettoPrice.onSale == false)
    }

    @Test func priceAmountsAreDecimal() throws {
        let data = try FixtureLoader.load("item_variants_response")
        let response = try decoder.decode(ItemVariantsResponse.self, from: data)
        let price = response.variants[0].prices[0]
        // Verify it's Decimal, not Double
        let formatted = "\(price.amount)"
        #expect(formatted == "12.95")
    }
}
