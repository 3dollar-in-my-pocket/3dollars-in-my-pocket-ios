import Foundation

public struct StoreWithDetailApiResponse: Decodable {
    public let store: StoreDetailApiResponse
    public let distanceM: Int
    public let creator: UserApiResponse
    public let images: ContentsWithCursorWithTotalCountResponse<StoreImageApiResponse>
    public let reviews: ContentsWithCursorWithTotalCountResponse<ReviewWithUserApiResponse>
    public let visits: StoreVisitCountsWithHistoryListApiResponse
    public let favorite: StoreFavoriteResponse
    public let tags: StoreTagResponse
}
