import Foundation

public protocol StoreCardComponent: Equatable, Hashable, Decodable {
    var type: SDComponentType { get }
}

public struct StoreRelatedStoresSectionResponse: Decodable, Hashable, StoreCardComponent {
    public let type: SDComponentType
    public let header: StoreRelatedStoresSectionHeaderResponse
    public let cards: [StoreImagePreviewCard]
    public let reference: [ExperimentReferenceResponse]
}

public struct StoreRelatedStoresSectionHeaderResponse: Decodable, Hashable {
    public let title: SDText
}

public struct StoreImagePreviewCard: Decodable, Hashable, StoreCardComponent {
    public let type: SDComponentType
    public let cardId: String
    public let image: SDImage
    public let title: SDText
    public let metricLabel: [SDChip]
    public let contextLabel: [SDChip]
    public let link: SDLink?
    public let style: SDSurfaceStyle
    public let refs: [StoreReferenceResponse]
    public let clickLog: SDClickLog?

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(SDComponentType.self, forKey: .type)
        self.cardId = try container.decode(String.self, forKey: .cardId)
        self.image = try container.decode(SDImage.self, forKey: .image)
        self.title = try container.decode(SDText.self, forKey: .title)
        self.metricLabel = try container.decode([SDChip].self, forKey: .metricLabel)
        self.contextLabel = try container.decode([SDChip].self, forKey: .contextLabel)
        self.link = try container.decodeIfPresent(SDLink.self, forKey: .link)
        self.style = try container.decode(SDSurfaceStyle.self, forKey: .style)
        self.refs = try container.decodeIfPresent([StoreReferenceResponse].self, forKey: .refs) ?? []
        self.clickLog = try container.decodeIfPresent(SDClickLog.self, forKey: .clickLog)
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case cardId
        case image
        case title
        case metricLabel
        case contextLabel
        case link
        case style
        case refs
        case clickLog
    }
}

public struct StoreReferenceResponse: Decodable, Hashable {
    public let type: String
    public let storeId: String
    public let storeType: String
}
