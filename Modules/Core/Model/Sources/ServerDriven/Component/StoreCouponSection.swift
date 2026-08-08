import Foundation

public struct StoreCouponSection: Decodable, Equatable, Hashable, StoreSectionComponent {
    public let type: StoreSectionType
    public let header: SDHeader?
    public let cards: [StoreCouponCard]
}

public struct StoreCouponCard: Decodable, Equatable, Hashable {
    public let cardId: String
    public let badge: SDChip?
    public let title: SDText
    public let subTitle: SDText
    public let trailingButton: SDButton
    public let style: SDSurfaceStyle
    public let clickLog: SDClickLog?
}
