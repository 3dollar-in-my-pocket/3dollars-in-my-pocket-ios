import Foundation

public struct SDAdCard: Decodable, Hashable, HomeListCardComponent {
    public let type: HomeListCardType
    public let cardId: String
    public let title: SDText?
    public let subTitle: SDText?
    public let labels: [SDChip]
    public let image: SDImage?
    public let trailingIcon: SDImage?
    public let link: SDLink?
    public let clickLog: SDClickLog
    public let impressionLog: SDImpressionLog

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(HomeListCardType.self, forKey: .type)
        self.cardId = try container.decode(String.self, forKey: .cardId)
        self.title = try container.decodeIfPresent(SDText.self, forKey: .title)
        self.subTitle = try container.decodeIfPresent(SDText.self, forKey: .subTitle)
        self.labels = try container.decodeIfPresent([SDChip].self, forKey: .labels) ?? []
        self.image = try container.decodeIfPresent(SDImage.self, forKey: .image)
        self.trailingIcon = try container.decodeIfPresent(SDImage.self, forKey: .trailingIcon)
        self.link = try container.decodeIfPresent(SDLink.self, forKey: .link)
        self.clickLog = try container.decode(SDClickLog.self, forKey: .clickLog)
        self.impressionLog = try container.decode(SDImpressionLog.self, forKey: .impressionLog)
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case cardId
        case title
        case subTitle
        case labels
        case image
        case trailingIcon
        case link
        case clickLog
        case impressionLog
    }
}
