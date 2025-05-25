import Foundation

public struct FeedResponse: Decodable {
    public let feedId: String
    public let category: FeedCategoryResponse?
    public let header: FeedHeaderResponse?
    public let body: FeedBodyResponse?
    public let link: SDLink
    public let createdAt: String
    public let updatedAt: String
    
    public enum CodingKeys: String, CodingKey {
        case feedId
        case category
        case header
        case body
        case link
        case createdAt
        case updatedAt
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        feedId = try container.decode(String.self, forKey: .feedId)
        category = try container.decode(FeedCategoryResponse.self, forKey: .category)

        // Decode header
        let headerContainer = try container.nestedContainer(keyedBy: FeedHeaderCodingKeys.self, forKey: .header)
        let headerType = try headerContainer.decode(FeedHeaderType.self, forKey: .type)
        let headerDecoder = try container.superDecoder(forKey: .header)
        switch headerType {
        case .general:
            header = try GeneralFeedHeaderResponse(from: headerDecoder)
        case .unknown:
            header = try GeneralFeedHeaderResponse(from: headerDecoder)
        }
        
        // Decode body
        if container.contains(.body),
           try container.decodeNil(forKey: .body) == false {
            let bodyContainer = try container.nestedContainer(keyedBy: FeedBodyCodingKeys.self, forKey: .body)
            let bodyType = try bodyContainer.decodeIfPresent(FeedBodyType.self, forKey: .type)
            let bodyDecoder = try container.superDecoder(forKey: .body)
            switch bodyType {
            case .contentOnly:
                body = try ContentOnlyFeedBodyResponse(from: bodyDecoder)
            case .contentWithTitle:
                body = try ContentWithTitleFeedBodyResponse(from: bodyDecoder)
            case .titleContentImages:
                body = try ContentWithImagesFeedBodyResponse(from: bodyDecoder)
            case .contentWithTitleAndImages:
                body = try ContentWithTitleAndImagesFeedBodyResponse(from: bodyDecoder)
            case .contentWithImages:
                body = try ContentWithImagesFeedBodyResponse(from: bodyDecoder)
            case .unknown:
                body = try ContentOnlyFeedBodyResponse(from: bodyDecoder)
            default:
                body = nil
            }
        } else {
            body = nil
        }
            
        link = try container.decode(SDLink.self, forKey: .link)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
    }
}

public struct FeedCategoryResponse: Decodable {
    public let categoryId: String
    public let name: SDText
    public let style: FeedStyleResponse
}

public struct FeedStyleResponse: Decodable {
    public let backgroundColor: String
}
