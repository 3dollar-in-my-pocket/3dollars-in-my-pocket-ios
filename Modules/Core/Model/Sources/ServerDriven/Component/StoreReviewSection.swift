import Foundation

public struct StoreReviewSection: Decodable, Equatable, Hashable, StoreSectionComponent {
    public let type: StoreSectionType
    public let header: SDHeader
    public let summary: StoreReviewSummary
    public let cards: [StoreReviewCard]
    public let more: SDActionBar?
}

public struct StoreReviewSummary: Decodable, Equatable, Hashable {
    public let title: SDText
    public let stars: SDRatingChip
    public let rating: SDText
    public let style: SDSurfaceStyle
}

public struct StoreReviewCard: Decodable, Equatable, Hashable {
    public let cardId: String
    public let header: SDHeader
    public let metadata: [SDChip]
    public let stars: SDRatingChip
    public let images: [SDImage]
    public let body: SDText
    public let like: SDToggleAction?
    public let reply: StoreReviewReply?
    public let link: SDLink?
    public let style: SDSurfaceStyle
    public let clickLog: SDClickLog?
}

public struct StoreReviewReply: Decodable, Equatable, Hashable {
    public let header: SDHeader
    public let body: SDText
    public let style: SDSurfaceStyle
}
