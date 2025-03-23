import Foundation

public struct FeedResponse: Decodable {
    public let feedId: String
    public let category: FeedCategoryResponse
    public let header: FeedHeaderResponse
    public let body: FeedContentResponse
    
    public init(from decoder: any Decoder) throws {
        
    }
}

public struct FeedCategoryResponse: Decodable {
    public let categoryId: String
    public let name: UiText
    public let style: FeedStyleResponse
}

public struct FeedStyleResponse: Decodable {
    public let backgroundColor: String
}

public struct FeedContentResponse: Decodable {
    public let title: UiText?
    
    
}
