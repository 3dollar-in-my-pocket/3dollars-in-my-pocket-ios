import Foundation

public struct StorePreviewMoreSection: Decodable, Equatable, Hashable, StoreSectionComponent {
    public let type: StoreSectionType
    public let sectionId: String?
    public let style: SDSurfaceStyle?
    public let header: SDHeader
    public let impressionLog: SDImpressionLog?
}
