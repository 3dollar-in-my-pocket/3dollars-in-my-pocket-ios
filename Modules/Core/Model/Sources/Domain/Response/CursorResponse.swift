import Foundation

public struct CursorString: Decodable {
    public let nextCursor: String?
    public let hasMore: Bool
}
