import Foundation

public struct StoreWithExtraResponse: Decodable, Hashable {
    public let store: StoreResponse
    public let openStatus: StoreOpenResponse
    public let distanceM: Int
    public let extra: StoreExtraResponse
}

public struct StoreExtraResponse: Decodable, Hashable {
    public let reviewsCount: Int?
    public let rating: Double?
    public let visitCounts: StoreVisitCountsResponse?
    public let tags: StoreTagResponse
}
