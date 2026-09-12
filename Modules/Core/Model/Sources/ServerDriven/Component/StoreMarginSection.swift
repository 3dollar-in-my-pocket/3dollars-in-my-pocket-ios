import Foundation

public struct StoreMarginSection: Decodable, Equatable, Hashable, StoreSectionComponent {
    public let type: StoreSectionType
    public let height: Double
}
