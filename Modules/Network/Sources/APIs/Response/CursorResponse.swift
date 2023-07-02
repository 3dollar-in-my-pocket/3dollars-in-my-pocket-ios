import Foundation

public struct CursorResponse: Decodable {
    public let nextCursor: String?
    public let hasMore: Bool
}
