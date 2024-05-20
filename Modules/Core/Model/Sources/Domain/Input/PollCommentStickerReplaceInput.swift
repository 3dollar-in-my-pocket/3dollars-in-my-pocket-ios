import Foundation

public struct PollCommentStickerListInput: Encodable {
    public let stickers: [PollCommentStickerInput]
    
    public init(stickers: [PollCommentStickerInput]) {
        self.stickers = stickers
    }
}

public struct PollCommentStickerInput: Encodable {
    public let stickerId: String
    
    public init(stickerId: String) {
        self.stickerId = stickerId
    }
}
