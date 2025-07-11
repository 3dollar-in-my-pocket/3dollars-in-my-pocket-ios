import Foundation

public struct SDLink: Decodable, Equatable, Hashable {
    public let type: SDLinkType
    public let link: String
}

public enum SDLinkType: String, Decodable {
    case web = "WEB"
    case appScheme = "APP_SCHEME"
    case unknown
    
    public init(from decoder: Decoder) throws {
        self = try SDLinkType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}
