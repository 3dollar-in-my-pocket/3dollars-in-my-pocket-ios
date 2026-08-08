import Foundation

public struct StoreEditSection: Decodable, Equatable, Hashable, StoreSectionComponent {
    public let type: StoreSectionType
    public let actionBars: [SDActionBar]
}
