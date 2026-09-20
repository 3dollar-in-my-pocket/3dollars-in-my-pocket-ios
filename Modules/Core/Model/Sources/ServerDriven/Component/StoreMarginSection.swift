import Foundation

public struct StoreMarginSection: Decodable, Equatable, Hashable, StoreSectionComponent {
    public let type: StoreSectionType
    public let sectionId: String?
    public let style: SDSurfaceStyle?
    public let height: Double
}
