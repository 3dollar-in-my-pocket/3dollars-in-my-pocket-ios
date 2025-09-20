import Foundation

public struct UserStoreDetailResponse: Decodable {
    public var store: UserStoreResponse
    public let openStatus: StoreOpenResponse
    public let distanceM: Int
    public let creator: UserResponse
    public let images: ContentsWithCursorWithTotalCountResponse<StoreImageResponse>
    public let reviews: ContentsWithCursorWithTotalCountResponse<StoreReviewWithWriterResponse>
    public let visits: StoreVisitListWithCountResponse
    public let favorite: StoreFavoriteResponse
    public let tags: StoreTagResponse
}
