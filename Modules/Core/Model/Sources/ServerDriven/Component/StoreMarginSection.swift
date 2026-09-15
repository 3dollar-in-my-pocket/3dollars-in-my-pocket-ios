import Foundation

public struct StoreMarginSection: Decodable, Equatable, Hashable, StoreSectionComponent {
    public let type: StoreSectionType
    public let sectionId: String?
    public let height: Double
}
