import Foundation

public struct LocalResponse<T: Decodable>: Decodable {
    public let meta: Meta
    public let documents: [T]
}

public extension LocalResponse {
    struct Meta: Decodable {
        let totalCount: Int
        let pageableCount: Int
        let isEnd: Bool
    }
}
