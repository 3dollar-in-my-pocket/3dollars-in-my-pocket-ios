import Foundation

public protocol FeedBodyResponse: Decodable {
    var type: FeedBodyType { get }
}

public enum FeedBodyType: String, Decodable {
    case contentOnly = "CONTENT_ONLY"
    case contentWithTitle = "CONTENT_WITH_TITLE"
    case titleContentImages = "TITLE_CONTENT_IMAGES"
    case contentWithTitleAndImages = "CONTENT_WITH_TITLE_AND_IMAGES"
}

public struct ContentOnlyFeedBodyResponse: FeedBodyResponse {
    public let type: FeedBodyType
    public let content: UiText
    public let style: FeedStyleResponse
}
