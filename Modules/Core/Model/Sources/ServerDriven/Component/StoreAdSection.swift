import Foundation

public struct StoreAdSection: Decodable, Equatable, Hashable, StoreSectionComponent {
    public let type: StoreSectionType
    public let sectionId: String?
    public let style: SDSurfaceStyle?
    public let cards: [SDAdCard]
    public let impressionLog: SDImpressionLog?
}
