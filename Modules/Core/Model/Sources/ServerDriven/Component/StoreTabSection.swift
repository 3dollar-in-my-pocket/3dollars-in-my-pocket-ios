import Foundation

public struct StoreTabSection: Decodable, Equatable, Hashable, StoreSectionComponent {
    public let type: StoreSectionType
    public let sectionId: String?
    public let style: SDSurfaceStyle?
    public let tabs: [SDActionBar]
}
