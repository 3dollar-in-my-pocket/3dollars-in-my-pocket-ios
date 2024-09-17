import Foundation

public struct StoreWithExtraResponse: Decodable, Hashable {
    public let store: StoreResponse
    public let marker: StoreMarkerResponse?
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

public struct StoreMarkerResponse: Decodable, Hashable {
    public let selected: StoreMarkerImageResponse
    public let unselected: StoreMarkerImageResponse
}

public struct StoreMarkerImageResponse: Decodable, Hashable {
    public let imageUrl: String
    public let width: Int
    public let height: Int
}
