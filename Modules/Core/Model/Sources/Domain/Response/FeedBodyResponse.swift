import Foundation

public protocol FeedBodyResponse: Decodable {
    var type: FeedBodyType { get }
}

public enum FeedBodyCodingKeys: String, CodingKey {
    case type
}

public enum FeedBodyType: String, Decodable {
    case contentOnly = "CONTENT_ONLY"
    case contentWithTitle = "CONTENT_WITH_TITLE"
    case titleContentImages = "TITLE_CONTENT_IMAGES"
    case contentWithImages = "CONTENT_WITH_IMAGES"
    case contentWithTitleAndImages = "CONTENT_WITH_TITLE_AND_IMAGES"
    case unknown
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(RawValue.self)
        self = FeedBodyType(rawValue: rawValue) ?? .unknown
    }
}

public struct ContentOnlyFeedBodyResponse: FeedBodyResponse {
    public let type: FeedBodyType
    public let content: UiText
    public let style: FeedStyleResponse
    public let contentLeadingImage: ImageResponse?
}

public struct ContentWithImagesFeedBodyResponse: FeedBodyResponse {
    public let type: FeedBodyType
    public let content: UiText
    public let images: [ImageResponse]
    public let style: FeedStyleResponse
}

public struct ContentWithTitleAndImagesFeedBodyResponse: FeedBodyResponse {
    public let type: FeedBodyType
    public let title: UiText
    public let content: UiText
    public let images: [ImageResponse]
    public let style: FeedStyleResponse
}

public struct ContentWithTitleFeedBodyResponse: FeedBodyResponse {
    public var type: FeedBodyType
    public let title: UiText
    public let content: UiText
    public let style: FeedStyleResponse
    public let additionalInfos: AdditionalInfos?
}

public struct AdditionalInfos: Decodable {
    public let reviewRating: Int?
}
