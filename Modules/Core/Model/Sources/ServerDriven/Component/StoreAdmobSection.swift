import Foundation

public struct StoreAdmobSection: Decodable, Equatable, Hashable, StoreSectionComponent {
    public let type: StoreSectionType
    public let cards: [StoreAdmobCard]
}

public struct StoreAdmobCard: Decodable, Equatable, Hashable {
    public let type: HomeListCardType
    public let cardId: String
    public let clickLog: SDClickLog
    public let impressionLog: SDImpressionLog
}
