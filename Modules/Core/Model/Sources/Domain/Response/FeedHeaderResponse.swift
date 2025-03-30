import Foundation

public protocol FeedHeaderResponse: Decodable {
    var type: FeedHeaderType { get }
}

public enum FeedHeaderCodingKeys: String, CodingKey {
    case type
}

public enum FeedHeaderType: String, Decodable {
    case general = "GENERAL"
    case unknown
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(RawValue.self)
        self = FeedHeaderType(rawValue: rawValue) ?? .unknown
    }
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
