import Foundation

public struct StickerApiResponse: Decodable {
    public let stickerId: String
    public let emoji: String
    public var count: Int
    public var reactedByMe: Bool
}
