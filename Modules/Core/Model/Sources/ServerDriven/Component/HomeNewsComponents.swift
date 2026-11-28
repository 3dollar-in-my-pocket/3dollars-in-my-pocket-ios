import Foundation

public enum HomeNewsItemType: String, Decodable {
    case contentCard = "CONTENT_CARD"
    case admobCard = "ADMOB_CARD"
    case unknown

    public init(from decoder: Decoder) throws {
        self = try HomeNewsItemType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

public enum HomeNewsItem: Hashable {
    case contentCard(HomeNewsContentCard)
    case admobCard(HomeListAdmobCardResponse)

    public var cardId: String {
        switch self {
        case .contentCard(let card):
            return card.cardId
        case .admobCard(let card):
            return card.cardId
        }
    }

    public var impressionLog: SDImpressionLog? {
        switch self {
        case .contentCard(let card):
            return card.impressionLog
        case .admobCard(let card):
            return card.impressionLog
        }
    }
}

public struct HomeNewsContentCard: Decodable, Hashable {
    public let cardId: String
    public let header: HomeNewsContentCardHeader
    public let bodyBlocks: [HomeNewsBodyBlock]
    public let link: SDLink?
    public let impressionLog: SDImpressionLog?
    public let clickLog: SDClickLog?

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.cardId = try container.decode(String.self, forKey: .cardId)
        self.header = try container.decode(HomeNewsContentCardHeader.self, forKey: .header)
        self.bodyBlocks = try container.decodeIfPresent([HomeNewsBodyBlock].self, forKey: .bodyBlocks) ?? []
        self.link = try container.decodeIfPresent(SDLink.self, forKey: .link)
        self.impressionLog = try container.decodeIfPresent(SDImpressionLog.self, forKey: .impressionLog)
        self.clickLog = try container.decodeIfPresent(SDClickLog.self, forKey: .clickLog)
    }

    private enum CodingKeys: String, CodingKey {
        case cardId
        case header
        case bodyBlocks
        case link
        case impressionLog
        case clickLog
    }
}

public struct HomeNewsContentCardHeader: Decodable, Hashable {
    public let badge: SDChip?
    public let trailingText: SDText?
    public let summary: HomeNewsCardSummary
}

public struct HomeNewsCardSummary: Decodable, Hashable {
    public let leadingImage: SDImage?
    public let overline: SDText?
    public let title: SDText
    public let metadata: [SDChip]

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.leadingImage = try container.decodeIfPresent(SDImage.self, forKey: .leadingImage)
        self.overline = try container.decodeIfPresent(SDText.self, forKey: .overline)
        self.title = try container.decode(SDText.self, forKey: .title)
        self.metadata = try container.decodeIfPresent([SDChip].self, forKey: .metadata) ?? []
    }

    private enum CodingKeys: String, CodingKey {
        case leadingImage
        case overline
        case title
        case metadata
    }
}

public struct HomeNewsBodyBlock: Decodable, Hashable {
    public let heading: HomeNewsBodyBlockHeading?
    public let images: [SDImage]
    public let textLeadingImage: SDImage?
    public let text: SDText?
    public let style: SDSurfaceStyle?

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.heading = try container.decodeIfPresent(HomeNewsBodyBlockHeading.self, forKey: .heading)
        self.images = try container.decodeIfPresent([SDImage].self, forKey: .images) ?? []
        self.textLeadingImage = try container.decodeIfPresent(SDImage.self, forKey: .textLeadingImage)
        self.text = try container.decodeIfPresent(SDText.self, forKey: .text)
        self.style = try container.decodeIfPresent(SDSurfaceStyle.self, forKey: .style)
    }

    private enum CodingKeys: String, CodingKey {
        case heading
        case images
        case textLeadingImage
        case text
        case style
    }
}

public struct HomeNewsBodyBlockHeading: Decodable, Hashable {
    public let leadingImage: SDImage?
    public let title: SDText
    public let trailingImages: [SDImage]

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.leadingImage = try container.decodeIfPresent(SDImage.self, forKey: .leadingImage)
        self.title = try container.decode(SDText.self, forKey: .title)
        self.trailingImages = try container.decodeIfPresent([SDImage].self, forKey: .trailingImages) ?? []
    }

    private enum CodingKeys: String, CodingKey {
        case leadingImage
        case title
        case trailingImages
    }
}

struct LossyHomeNewsItem: Decodable {
    let item: HomeNewsItem?

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: TypeCodingKeys.self)
        switch try container.decode(HomeNewsItemType.self, forKey: .type) {
        case .contentCard:
            item = (try? HomeNewsContentCard(from: decoder)).map { .contentCard($0) }
        case .admobCard:
            item = (try? HomeListAdmobCardResponse(from: decoder)).map { .admobCard($0) }
        case .unknown:
            item = nil
        }
    }

    private enum TypeCodingKeys: String, CodingKey {
        case type
    }
}
