import Foundation

nonisolated struct SearchResult: Decodable, Sendable {
    let data: SearchData
    let meta: PaginationMeta

    nonisolated struct SearchData: Decodable, Sendable {
        let hits: [SearchHit]
    }
}
