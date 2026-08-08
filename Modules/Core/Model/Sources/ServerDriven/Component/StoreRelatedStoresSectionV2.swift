import Foundation

public struct StoreRelatedStoresSectionV2: Decodable, Equatable, Hashable, StoreSectionComponent {
    public let type: StoreSectionType
    public let header: SDHeader
    public let cards: [StoreImagePreviewCard]
    public let reference: [ExperimentReferenceResponse]
    public let impressionLog: SDImpressionLog
}
