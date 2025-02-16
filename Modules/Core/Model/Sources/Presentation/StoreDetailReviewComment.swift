public struct StoreDetailReviewComment: Hashable {
    public let id: String
    public let content: String
    public let updatedAt: String
    public let isOwner: Bool
    
    init(response: CommentResponse) {
        self.id = response.commentId
        self.content = response.content
        self.updatedAt = response.updatedAt
        self.isOwner = response.isOwner
    }
}
