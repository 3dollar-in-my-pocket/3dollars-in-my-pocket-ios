import Foundation

public struct LocalResponse<T: Decodable>: Decodable {
    let meta: Meta
    let documents: [T]
}

extension LocalResponse {
    struct Meta: Decodable {
        let totalCount: Int
        let pageableCount: Int
        let isEnd: Bool
    }
}
