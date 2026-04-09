import Foundation

nonisolated struct SearchSuggestion: Decodable, Sendable, Identifiable {
    var id: Int { itemId }
    let itemId: Int
    let itemName: String
}
