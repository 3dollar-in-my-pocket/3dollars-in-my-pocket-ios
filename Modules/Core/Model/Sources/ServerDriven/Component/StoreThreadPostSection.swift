import Foundation

public struct StoreThreadPostSection: Decodable, Equatable, Hashable, StoreSectionComponent {
    public let type: StoreSectionType
    public let sectionId: String?
    public let style: SDSurfaceStyle?
    public let header: SDHeader
    public let cards: [StoreThreadPostCard]
    public let impressionLog: SDImpressionLog?
}

public struct StoreThreadPostCard: Decodable, Equatable, Hashable {
    public let platform: StoreSnsPostPlatform
    public let permalink: String
    public let clickLog: SDClickLog?

    enum CodingKeys: String, CodingKey {
        case platform
        case permalink
        case clickLog
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        platform = try container.decodeIfPresent(StoreSnsPostPlatform.self, forKey: .platform) ?? .threads
        permalink = try container.decode(String.self, forKey: .permalink)
        clickLog = try container.decodeIfPresent(SDClickLog.self, forKey: .clickLog)
    }
}

public enum StoreSnsPostPlatform: String, Decodable {
    case threads = "THREADS"
    case instagram = "INSTAGRAM"
    case unknown

    public init(from decoder: Decoder) throws {
        self = try StoreSnsPostPlatform(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}
