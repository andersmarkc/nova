import Foundation

nonisolated struct ItemVariantsResponse: Decodable, Sendable {
    let item: ItemDetail
    let attributeDefinitions: [AttributeDefinition]
    let variants: [ProductVariant]
}

nonisolated struct ItemDetail: Decodable, Sendable, Identifiable {
    let id: Int
    let name: String
    let slug: String?
    let description: String?
    let imageUrl: String?
}

nonisolated struct AttributeDefinition: Decodable, Sendable {
    let name: String
    let label: String
    let dataType: String
    let options: [String: AnyCodableValue]?
}
