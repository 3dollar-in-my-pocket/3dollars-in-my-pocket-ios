import Foundation

public struct StickerApiResponse: Decodable {
    public let stickerId: String
    public let emoji: String
    public let count: Int
    public let reactedByMe: Bool
}
