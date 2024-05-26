import Foundation

public struct StoreReviewStickerListReplaceInput:Encodable {
    public let stickers: [StoreReviewStickerReplaceInput]
    
    public init(stickers: [StoreReviewStickerReplaceInput]) {
        self.stickers = stickers
    }
}


public struct StoreReviewStickerReplaceInput: Encodable {
    public let stickerId: String
    
    public init(stickerId: String) {
        self.stickerId = stickerId
    }
}
