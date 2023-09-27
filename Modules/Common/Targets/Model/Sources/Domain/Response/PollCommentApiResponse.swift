import Foundation

public struct PollCommentWithUserRecursiveApiResponse: Decodable {
    public let current: PollCommentWithUserApiResponse
}

public struct PollCommentWithUserApiResponse: Decodable {
    public let comment: PollCommentApiResponse
    public let commentWriter: UserApiResponse
    public let commentReport: PollCommentReportApiResponse
}

public struct PollCommentApiResponse: Decodable {
    public let commentId: String
    public let content: String
    public let status: PollCommentStatus
    public let createdAt: String
    public let updatedAt: String

    public enum PollCommentStatus: String, Decodable {
        case active
        case blinded
        case deleted
        case unknown

        public init(from decoder: Decoder) throws {
            self = try PollCommentStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
        }
    }
}

public struct PollCommentReportApiResponse: Decodable {
    public let reportedByMe: Bool
}
