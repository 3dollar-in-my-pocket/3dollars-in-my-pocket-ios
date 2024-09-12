import Foundation

public struct AdvertisementListResponse: Decodable {
    public let advertisements: [AdvertisementResponse]
}

public struct AdvertisementResponse: Decodable, Hashable {
    public let advertisementId: Int
    public let title: AdvertisementSectionResponse?
    public let subTitle: AdvertisementSectionResponse?
    public let extra: AdvertisementSectionResponse?
    public let background: AdvertisementBackgroundResponse?
    public let link: AdvertisementLinkResponse?
    public let image: AdvertisementImageResponse?
    public let metadata: AdvertisementMetadataResponse?
}

public struct AdvertisementSectionResponse: Decodable, Hashable {
    public let content: String
    public let fontColor: String?
}

public struct AdvertisementBackgroundResponse: Decodable, Hashable {
    public let color: String
}

public struct AdvertisementLinkResponse: Decodable, Hashable {
    public enum LinkType: String, Decodable {
        case web = "WEB"
        case appScheme = "APP_SCHEME"
        case unknown
        
        public init(from decoder: Decoder) throws {
            self = try LinkType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
        }
    }
    
    public let type: LinkType
    public let url: String
}

public struct AdvertisementImageResponse: Decodable, Hashable {
    public let url: String
    public let width: Int?
    public let height: Int?
}

public struct AdvertisementMetadataResponse: Decodable, Hashable {
    public let exposureIndex: Int?
}
