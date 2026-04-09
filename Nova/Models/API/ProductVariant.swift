import Foundation

nonisolated struct ProductVariant: Decodable, Sendable, Identifiable {
    let id: Int
    let productName: String
    let productSlug: String?
    let variantName: String?
    let variantSlug: String?
    let brand: String?
    let size: String?
    let unit: String?
    let ean: String?
    let imageUrl: String?
    let variantAttributes: [String: AnyCodableValue]?
    let minPrice: Decimal?
    let prices: [Price]
}

/// Handles mixed-type JSON values in variant_attributes
/// (e.g., `{"organic": true, "section": "Mejeri", "fat_percentage": 0.1}`)
nonisolated enum AnyCodableValue: Decodable, Sendable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if container.decodeNil() {
            self = .null
        } else {
            self = .null
        }
    }

    var stringValue: String {
        switch self {
        case .string(let value): value
        case .int(let value): "\(value)"
        case .double(let value): "\(value)"
        case .bool(let value): value ? "true" : "false"
        case .null: ""
        }
    }
}
