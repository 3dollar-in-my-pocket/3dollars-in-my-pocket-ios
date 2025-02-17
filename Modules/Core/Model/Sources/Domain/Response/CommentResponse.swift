public struct ContentListCommentResponse: Decodable {
    public let contents: [CommentResponse]
}

public struct CommentResponse: Decodable {
    public let commentId: String
    public let content: String
    public let status: Status
    public let createdAt: String
    public let updatedAt: String
    public let isOwner: Bool

    public enum Status: String, Decodable {
        case active = "ACTIVE"
        case blinded = "BLINDED"
        case deleted = "DELETED"
        case unknown

        public init(from decoder: Decoder) throws {
            self = try Status(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
        }
    }
}
