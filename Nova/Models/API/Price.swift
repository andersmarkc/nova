import Foundation

nonisolated struct Price: Decodable, Sendable {
    let shopId: Int
    let shopName: String
    let amount: Decimal
    let onSale: Bool
    let salesPrice: Decimal?
    let unitPrice: Decimal?
    let unitType: String?
    let promotionText: String?

    enum CodingKeys: String, CodingKey {
        case shopId, shopName, amount, onSale, salesPrice, unitPrice, unitType, promotionText
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        shopId = try container.decode(Int.self, forKey: .shopId)
        shopName = try container.decode(String.self, forKey: .shopName)
        amount = try container.decodeDecimalFromString(forKey: .amount)
        onSale = try container.decode(Bool.self, forKey: .onSale)
        salesPrice = try container.decodeOptionalDecimalFromString(forKey: .salesPrice)
        unitPrice = try container.decodeOptionalDecimalFromString(forKey: .unitPrice)
        unitType = try container.decodeIfPresent(String.self, forKey: .unitType)
        promotionText = try container.decodeIfPresent(String.self, forKey: .promotionText)
    }
}

extension KeyedDecodingContainer {
    /// Decodes a Decimal that may arrive as either a JSON string or a JSON number.
    nonisolated func decodeDecimalFromString(forKey key: Key) throws -> Decimal {
        if let stringValue = try? decode(String.self, forKey: key),
           let decimal = Decimal(string: stringValue) {
            return decimal
        }
        return try decode(Decimal.self, forKey: key)
    }

    /// Decodes an optional Decimal that may arrive as either a JSON string, number, or null.
    nonisolated func decodeOptionalDecimalFromString(forKey key: Key) throws -> Decimal? {
        if let stringValue = try? decode(String.self, forKey: key),
           let decimal = Decimal(string: stringValue) {
            return decimal
        }
        return try decodeIfPresent(Decimal.self, forKey: key)
    }
}
