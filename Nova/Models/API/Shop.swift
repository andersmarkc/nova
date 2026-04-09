import Foundation

nonisolated struct Shop: Decodable, Sendable, Identifiable {
    let id: Int
    let name: String
}
