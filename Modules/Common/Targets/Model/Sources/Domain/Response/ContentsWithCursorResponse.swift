import Foundation

public struct ContentsWithCursorResposne<T: Decodable>: Decodable {
    public let contents: [T]
    public let cursor: CursorResponse
}
