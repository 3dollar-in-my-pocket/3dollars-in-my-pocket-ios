import Foundation

public struct LinkResponse: Decodable {
    public let type: LinkType
    public let link: String
}

public enum LinkType: String, Decodable {
    case web = "WEB"
    case appScheme = "APP_SCHEME"
    case unknown
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(RawValue.self)
        self = LinkType(rawValue: rawValue) ?? .unknown
    }
}
