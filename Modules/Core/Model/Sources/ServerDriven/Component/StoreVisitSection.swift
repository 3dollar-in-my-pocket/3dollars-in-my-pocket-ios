import Foundation

public struct StoreVisitSection: Decodable, Equatable, Hashable, StoreSectionComponent {
    public let type: StoreSectionType
    public let header: SDHeader
    public let summary: StoreVisitSummary
    public let history: StoreVisitSectionHistory
}

public struct StoreVisitSummary: Decodable, Equatable, Hashable {
    public let chips: [SDChip]
}

public struct StoreVisitSectionHistory: Decodable, Equatable, Hashable {
    public let items: [SDChip]
    public let moreText: SDText?
    public let style: SDSurfaceStyle
}
