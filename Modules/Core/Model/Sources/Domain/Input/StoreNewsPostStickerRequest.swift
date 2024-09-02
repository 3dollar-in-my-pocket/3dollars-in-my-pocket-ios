import Foundation

public struct StoreNewsPostStickersReplaceRequest: Encodable {
    public let stickers: [StoreNewsPostStickerRequest]
    
    public init(stickers: [StoreNewsPostStickerRequest]) {
        self.stickers = stickers
    }
}

public struct StoreNewsPostStickerRequest: Encodable {
    public let stickerId: String
    
    public init(stickerId: String) {
        self.stickerId = stickerId
    }
}
