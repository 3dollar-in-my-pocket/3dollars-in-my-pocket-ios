public struct PostResponse: Decodable {
    public let postId: String
    public let body: String
    public let sections: [PostSectionResponse]
    public let isOwner: Bool
    public var stickers: [StickerResponse]
    public let createdAt: String
    public let updatedAt: String
}

public struct PostSectionResponse: Decodable {
    public let sectionType: String
    public let url: String
    public let ratio: Double
}

public struct PostWithStoreResponse: Decodable {
    public let postId: String
    public let body: String
    public let sections: [PostSectionResponse]
    public let isOwner: Bool
    public let store: StoreResponse
    public var stickers: [StickerResponse]
    public let createdAt: String
    public let updatedAt: String
}
