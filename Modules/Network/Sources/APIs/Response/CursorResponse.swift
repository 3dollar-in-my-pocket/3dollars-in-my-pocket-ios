import Foundation

public struct CursorResponse: Decodable {
    let nextCursor: String?
    let hasMore: Bool
}
