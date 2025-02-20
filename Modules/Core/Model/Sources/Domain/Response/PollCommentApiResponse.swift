import Foundation

public struct PollCommentWithUserRecursiveApiResponse: Decodable {
    public let current: PollCommentWithUserApiResponse
}

public struct PollCommentWithUserApiResponse: Decodable {
    public let comment: CommentResponse
    public let commentWriter: UserResponse
    public let commentReport: PollCommentReportApiResponse
    public let poll: PollWithSelectedOptionsApiResponse
    public var stickers: [StickerResponse]
}

public struct PollCommentReportApiResponse: Decodable {
    public let reportedByMe: Bool
}

public struct PollWithSelectedOptionsApiResponse: Decodable {
    public let isWriter: Bool
    public let selectedOptions: [PollOptionApiResponse]
}

public struct PollOptionApiResponse: Decodable {
    public let optionId: String
    public let name: String
}
