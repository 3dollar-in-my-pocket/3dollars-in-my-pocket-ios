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
    public let permalink: String
    public let clickLog: SDClickLog?
}
