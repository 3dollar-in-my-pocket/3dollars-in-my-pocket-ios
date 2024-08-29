public struct BossStoreDetailRecentPost {
    public let storeName: String
    public let categoryIconUrl: String?
    public let totalCount: Int
    public let post: PostResponse
    
    public init(storeName: String, categoryIconUrl: String? = nil, totalCount: Int, post: PostResponse) {
        self.storeName = storeName
        self.categoryIconUrl = categoryIconUrl
        self.totalCount = totalCount
        self.post = post
    }
    
    public init(response: PostWithStoreResponse) {
        storeName = response.store.storeName
        categoryIconUrl = response.store.categories.first?.imageUrl
        totalCount = 0
        post = PostResponse(
            postId: response.postId,
            body: response.body,
            sections: response.sections,
            isOwner: response.isOwner,
            stickers: response.stickers,
            createdAt: response.createdAt,
            updatedAt: response.updatedAt
        )
    }
}
