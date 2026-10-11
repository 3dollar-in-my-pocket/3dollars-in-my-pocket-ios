import Foundation

public enum HomeCurationItemType: String, Decodable {
    case carousel = "CAROUSEL"
    case admobCard = "ADMOB_CARD"
    case unknown

    public init(from decoder: Decoder) throws {
        self = try HomeCurationItemType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

public enum HomeCurationCardType: String, Decodable {
    case imagePreviewCard = "IMAGE_PREVIEW_CARD"
    case admobCard = "ADMOB_CARD"
    case unknown

    public init(from decoder: Decoder) throws {
        self = try HomeCurationCardType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

public enum HomeCurationItem: Hashable {
    case carousel(HomeCurationCarousel)
    case admobCard(HomeListAdmobCardResponse)
}

public enum HomeCurationCard: Hashable {
    case imagePreviewCard(StoreImagePreviewCard)
    case admobCard(HomeListAdmobCardResponse)

    public var cardId: String {
        switch self {
        case .imagePreviewCard(let card):
            return card.cardId
        case .admobCard(let card):
            return card.cardId
        }
    }
}

public struct HomeCurationCarousel: Decodable, Hashable {
    public let carouselId: String
    public let header: SDHeader
    public let defaultCategoryId: String
    public let categoryFilters: [HomeCurationCategoryFilter]
    public let cards: [HomeCurationCard]

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.carouselId = try container.decode(String.self, forKey: .carouselId)
        self.header = try container.decode(SDHeader.self, forKey: .header)
        self.defaultCategoryId = try container.decode(String.self, forKey: .defaultCategoryId)
        self.categoryFilters = try container.decode([HomeCurationCategoryFilter].self, forKey: .categoryFilters)
        self.cards = try container.decodeIfPresent([LossyHomeCurationCard].self, forKey: .cards)?
            .compactMap(\.card) ?? []
    }

    private enum CodingKeys: String, CodingKey {
        case carouselId
        case header
        case defaultCategoryId
        case categoryFilters
        case cards
    }
}

public struct HomeCurationCategoryFilter: Decodable, Hashable {
    public let categoryId: String
    public let selected: SDChip
    public let unselected: SDChip
    public let clickLog: SDClickLog
}

struct LossyHomeCurationItem: Decodable {
    let item: HomeCurationItem?

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: TypeCodingKeys.self)
        switch try container.decode(HomeCurationItemType.self, forKey: .type) {
        case .carousel:
            item = .carousel(try HomeCurationCarousel(from: decoder))
        case .admobCard:
            item = .admobCard(try HomeListAdmobCardResponse(from: decoder))
        case .unknown:
            item = nil
        }
    }
}

struct LossyHomeCurationCard: Decodable {
    let card: HomeCurationCard?

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: TypeCodingKeys.self)
        switch try container.decode(HomeCurationCardType.self, forKey: .type) {
        case .imagePreviewCard:
            card = .imagePreviewCard(try StoreImagePreviewCard(from: decoder))
        case .admobCard:
            card = .admobCard(try HomeListAdmobCardResponse(from: decoder))
        case .unknown:
            card = nil
        }
    }
}

private enum TypeCodingKeys: String, CodingKey {
    case type
}
