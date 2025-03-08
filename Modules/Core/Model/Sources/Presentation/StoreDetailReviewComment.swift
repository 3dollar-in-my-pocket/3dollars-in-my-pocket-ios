public struct StoreDetailReviewComment: Hashable {
    public let id: String
    public let content: String
    public let updatedAt: String
    public let isOwner: Bool
    public let name: String
    
    init(response: CommentResponse) {
        self.id = response.commentId
        self.content = response.content
        self.updatedAt = response.updatedAt
        self.isOwner = response.isOwner
        self.name = response.writer.name
    }
}
