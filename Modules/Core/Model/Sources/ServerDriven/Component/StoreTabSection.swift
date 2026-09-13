import Foundation

public struct StoreTabSection: Decodable, Equatable, Hashable, StoreSectionComponent {
    public let type: StoreSectionType
    public let sectionId: String?
    public let tabs: [SDActionBar]
}
