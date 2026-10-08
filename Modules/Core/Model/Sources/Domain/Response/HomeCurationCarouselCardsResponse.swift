import Foundation

public struct HomeCurationCarouselCardsResponse: Decodable {
    public let cards: [HomeCurationCard]

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.cards = try container.decode([LossyHomeCurationCard].self, forKey: .cards).compactMap(\.card)
    }

    private enum CodingKeys: String, CodingKey {
        case cards
    }
}
