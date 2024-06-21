public struct PostApiResponse: Decodable {
    public let postId: String
    public let body: String
    public let sections: [PostSectionApiResponse]
    public let isOwner: Bool
    public let createdAt: String
    public let updatedAt: String
}

public struct PostSectionApiResponse: Decodable {
    public let sectionType: String
    public let url: String
    public let ratio: Double
}
