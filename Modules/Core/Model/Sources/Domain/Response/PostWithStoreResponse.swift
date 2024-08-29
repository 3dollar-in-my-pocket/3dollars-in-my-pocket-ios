public struct PostWithStoreResponse: Decodable {
    public let postId: String
    public let body: String
    public let sections: [PostSectionResponse]
    public let isOwner: Bool
    public let store: StoreApiResponse
    public let stickers: [StickerResponse]
    public let createdAt: String
    public let updatedAt: String
}
