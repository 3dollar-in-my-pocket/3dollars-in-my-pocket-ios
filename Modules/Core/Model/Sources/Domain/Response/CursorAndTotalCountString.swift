import Foundation

public struct CursorAndTotalCountString: Decodable {
    public let totalCount: Int
    public let nextCursor: String?
    public let hasMore: Bool
}

