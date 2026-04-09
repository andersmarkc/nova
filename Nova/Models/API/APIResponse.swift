import Foundation

nonisolated struct APIDataResponse<T: Decodable & Sendable>: Decodable, Sendable {
    let data: T
}

nonisolated struct PaginationMeta: Decodable, Sendable {
    let page: Int
    let perPage: Int
    let total: Int
    let query: String?
}
