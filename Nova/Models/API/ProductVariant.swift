import Foundation

nonisolated struct ProductVariant: Decodable, Sendable, Identifiable {
    let id: String
    let productName: String
    let variantName: String?
    let brand: String?
    let size: String?
    let unit: String?
    let ean: String?
    let imageUrl: String?
    let variantAttributes: [String: String]?
    let prices: [Price]
}
