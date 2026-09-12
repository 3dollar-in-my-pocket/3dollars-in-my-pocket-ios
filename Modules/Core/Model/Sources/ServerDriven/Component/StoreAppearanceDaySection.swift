import Foundation

public struct StoreAppearanceDaySection: Decodable, Equatable, Hashable, StoreSectionComponent {
    public let type: StoreSectionType
    public let header: SDHeader
    public let items: [StoreAppearanceDayItem]
}

public struct StoreAppearanceDayItem: Decodable, Equatable, Hashable {
    public let leadingText: SDText
    public let primaryText: SDText
    public let secondaryText: SDText?
    public let style: SDSurfaceStyle
}
