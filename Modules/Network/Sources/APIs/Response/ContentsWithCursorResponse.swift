import Foundation

public struct ContentsWithCursorResposne<T: Decodable>: Decodable {
    let contents: [T]
    let cursor: CursorResponse
}
