import Foundation

public struct PollWithMetaApiResponse: Decodable {
    public let poll: PollApiResponse
    public let pollWriter: UserApiResponse
    public let meta: PollMetaApiResponse
}

public struct PollApiResponse: Decodable {
    public let createdAt: String
    public let updatedAt: String
    public let pollId: String
    public let category: PollCategoryApiResponse
    public let content: PollContentApiResponse
    public let options: [PollOptionApiResponse]
    public let period: PollPeriodApiResponse
}

public struct PollCategoryApiResponse: Decodable {
    public let categoryId: String
    public let title: String
}

public struct PollContentApiResponse: Decodable {
    public let title: String
}

public struct PollOptionApiResponse: Decodable {
    public let optionId: String
    public let name: String
    public let choice: PollOptionChoiceApiResponse
}

public struct PollOptionChoiceApiResponse: Decodable {
    public let count: Int
    public let ratio: Double
    public let selectedByMe: Bool
}

public struct PollPeriodApiResponse: Decodable {
    public let startDateTime: String
    public let endDateTime: String
}

public struct PollMetaApiResponse: Decodable {
    public let totalParticipantsCount: Int
    public let totalCommentsCount: Int
}
