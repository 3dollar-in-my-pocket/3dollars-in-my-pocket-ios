public struct PostWithStoreApiResponse: Decodable {
    public let postId: String
    public let body: String
    public let sections: [PostSectionApiResponse]
    public let isOwner: Bool
    public let createdAt: String
    public let updatedAt: String
    public let store: StoreApiResponse
}
