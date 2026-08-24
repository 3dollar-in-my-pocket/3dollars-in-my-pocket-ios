import Foundation

public struct HomeListSectionResponse: Decodable {
    public let cards: [any HomeListCardComponent]
    public let cursor: CursorString?
    public let focusBounds: LocationBoundsResponse?

    public enum CodingKeys: String, CodingKey {
        case cards
        case cursor
        case focusBounds
    }

    public init(
        cards: [any HomeListCardComponent],
        cursor: CursorString?,
        focusBounds: LocationBoundsResponse? = nil
    ) {
        self.cards = cards
        self.cursor = cursor
        self.focusBounds = focusBounds
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.cursor = try container.decodeIfPresent(CursorString.self, forKey: .cursor)
        self.focusBounds = try container.decodeIfPresent(LocationBoundsResponse.self, forKey: .focusBounds)

        var cardsArray = try container.nestedUnkeyedContainer(forKey: .cards)
        var typeProbe = cardsArray
        var decodedCards: [any HomeListCardComponent] = []

        while !cardsArray.isAtEnd {
            let preview = try cardsArray.decode(HomeListCardTypePreview.self)
            let cardDecoder = try typeProbe.superDecoder()

            switch preview.type {
            case .basicCard:
                decodedCards.append(try HomeListBasicCardResponse(from: cardDecoder))
            case .admobCard:
                decodedCards.append(try HomeListAdmobCardResponse(from: cardDecoder))
            case .emptyCard:
                decodedCards.append(try HomeListEmptyCardResponse(from: cardDecoder))
            case .unknown:
                continue
            }
        }
        self.cards = decodedCards
    }
}

private struct HomeListCardTypePreview: Decodable {
    let type: HomeListCardType
}
