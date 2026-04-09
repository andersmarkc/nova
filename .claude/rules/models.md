---
paths:
  - "Nova/Models/**/*.swift"
---

# Models rules

## API response models (Models/API/)

Every struct in this directory maps to a Pulsar JSON response.

- Always `struct`, always `Codable`, always `Sendable`
- Define explicit `CodingKeys` even when using `.convertFromSnakeCase` decoder
- Money fields: `Decimal`, never `Float` or `Double`
- Date fields: decoded with ISO8601DateFormatter
- Optional fields match Pulsar nullability (check Pulsar schema)
- IDs are `Int` (Pulsar uses bigint primary keys)

```swift
struct Price: Codable, Sendable {
    let id: Int
    let amount: Decimal
    let currency: String
    let onSale: Bool
    let salesPrice: Decimal?
    let unitPrice: Decimal?
    let unitType: String?
    let promotionText: String?
    let validFrom: Date?
    let validUntil: Date?

    enum CodingKeys: String, CodingKey {
        case id, amount, currency
        case onSale = "on_sale"
        case salesPrice = "sales_price"
        case unitPrice = "unit_price"
        case unitType = "unit_type"
        case promotionText = "promotion_text"
        case validFrom = "valid_from"
        case validUntil = "valid_until"
    }
}
```

## Local persistence models (Models/Local/)

SwiftData `@Model` classes for offline storage. These are NOT the same as API models.
Create explicit mapping between API models and SwiftData models.
