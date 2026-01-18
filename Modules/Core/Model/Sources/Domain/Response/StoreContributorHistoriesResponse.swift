import Foundation

public struct StoreContributorHistoriesResponse: Decodable {
    public let data: StoreContributorHistoriesSection
}

public struct StoreContributorHistoriesSection: Decodable {
    public let type: String
    public let cards: [StoreContributorCard]
    public let cursor: CursorString
}

public struct StoreContributorCard: Decodable {
    public let data: StoreContributorCardData

    enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(SDUComponentTypes.self, forKey: .type)

        switch type {
        case .calloutCard:
            self.data = .callout(try CalloutCard(from: decoder))
        case .iconTextCard:
            self.data = .iconText(try IconTextCardData(from: decoder))
        case .unknown:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unknown component type"
            )
        }
    }
}

public enum StoreContributorCardData {
    case callout(CalloutCard)
    case iconText(IconTextCardData)
}

