import Foundation

public struct ContentsWithCursorWithTotalCountResponse<T: Decodable>: Decodable {
    public let contents: [T]
    public let cursor: CursorWithTotalCountResponse
}
