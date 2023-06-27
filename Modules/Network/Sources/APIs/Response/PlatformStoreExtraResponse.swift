import Foundation

public struct PlatformStoreExtraResponse: Decodable {
    let reviewsCount: Int?
    let rating: Double?
    let visitCounts: StoreVisitCountsResponse?
}
