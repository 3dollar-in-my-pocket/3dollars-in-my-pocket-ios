import Foundation

public struct StickerResponse: Decodable {
    public let stickerId: String
    public let emoji: String
    public var count: Int
    public var reactedByMe: Bool
}
