import Foundation

public struct CursorWithTotalCountResponse: Decodable {
    public let totalCount: Int
    public let nextCursor: String?
    public let hasMore: Bool
}

