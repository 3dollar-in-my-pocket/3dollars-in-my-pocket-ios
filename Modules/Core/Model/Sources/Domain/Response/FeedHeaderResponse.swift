import Foundation

public protocol FeedHeaderResponse: Decodable {
    var type: FeedHeaderType { get }
}

public enum FeedHeaderType: String, Decodable {
    case general = "GENERAL"
}

public struct GeneralFeedHeaderResponse: FeedHeaderResponse {
    public let type: FeedHeaderType
    public let image: ImageResponse
    public let top: UiText
    public let content: UiText
    public let metadata: [FeedHeaderMetadataResponse]
}

public struct FeedHeaderMetadataResponse: Decodable {
    public let icon: ImageResponse
    public let content: UiText
}
