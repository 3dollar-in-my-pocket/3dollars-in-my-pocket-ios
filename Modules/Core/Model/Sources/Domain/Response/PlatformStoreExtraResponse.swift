import Foundation

public struct PlatformStoreExtraResponse: Decodable {
    public let reviewsCount: Int?
    public let rating: Double?
    public let visitCounts: StoreVisitCountsResponse?
    public let tags: StoreTagResponse
}
