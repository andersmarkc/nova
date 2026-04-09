import Foundation

nonisolated struct SearchHit: Decodable, Sendable, Identifiable {
    let id: String
    let itemId: Int
    let itemName: String
    let brand: String?
    let variantName: String?
    let productName: String
    let minPrice: Decimal
    let onSale: Bool
    let shopIds: [Int]
    let imageUrl: String?
    let ean: String?
}
