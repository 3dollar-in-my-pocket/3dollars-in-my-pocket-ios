import Foundation

public struct HomeNewsSectionResponse: Decodable {
    public let header: SDHeader?
    public let items: [HomeNewsItem]
    public let cursor: HomeNewsCursor
    public let impressionLog: SDImpressionLog?

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.header = try container.decodeIfPresent(SDHeader.self, forKey: .header)
        self.items = try container.decodeIfPresent([LossyHomeNewsItem].self, forKey: .items)?
            .compactMap(\.item) ?? []
        self.cursor = try container.decodeIfPresent(HomeNewsCursor.self, forKey: .cursor) ?? HomeNewsCursor()
        self.impressionLog = try container.decodeIfPresent(SDImpressionLog.self, forKey: .impressionLog)
    }

    private enum CodingKeys: String, CodingKey {
        case header
        case items
        case cursor
        case impressionLog
    }
}

public struct HomeNewsCursor: Decodable, Equatable {
    public let nextCursor: String?
    public let hasMore: Bool

    public init(nextCursor: String? = nil, hasMore: Bool = false) {
        self.nextCursor = nextCursor
        self.hasMore = hasMore
    }
}
