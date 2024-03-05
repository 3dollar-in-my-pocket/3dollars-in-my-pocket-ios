import Foundation

public struct PollWithMetaApiResponse: Decodable {
    public let poll: PollApiResponse
    public let pollWriter: UserApiResponse
    public let meta: PollMetaApiResponse
}

public struct PollListWithUserPollMetaApiResponse: Decodable {
    public let polls: ContentsCursorResponsePollBasicApiResponse
    public let meta: PollUserMetaApiResponse
}

public struct ContentsCursorResponsePollBasicApiResponse: Decodable {
    public let contents: [PollBasicApiResponse]
    public let cursor: CursorResponse
}

public struct PollBasicApiResponse: Decodable {
    public let poll: PollApiResponse
}

public struct PollUserMetaApiResponse: Decodable {
    public let totalParticipantsCount: Int
}

public struct PollApiResponse: Decodable {
    public let createdAt: String
    public let updatedAt: String
    public let pollId: String
    public let category: PollCategoryApiResponse
    public let content: PollContentApiResponse
    public let options: [PollOptionWithChoiceApiResponse]
    public let period: PollPeriodApiResponse
}

public struct PollCategoryApiResponse: Decodable {
    public let categoryId: String
    public let title: String
}

public struct PollContentApiResponse: Decodable {
    public let title: String
}

public struct PollOptionWithChoiceApiResponse: Decodable {
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
