import Foundation

public struct ContentsWithCursorResponse<T: Decodable>: Decodable {
    public let contents: [T]
    public let cursor: CursorString
}
