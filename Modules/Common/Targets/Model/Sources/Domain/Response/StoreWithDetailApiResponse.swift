import Foundation

public struct StoreWithDetailApiResponse: Decodable {
    public let store: StoreDetailApiResponse
    public let distanceM: Int
    public let creator: UserApiResponse
    public let images: ContentsWithCursorResposne<StoreImageApiResponse>
    public let reviews: ContentsWithCursorResposne<ReviewWithUserApiResponse>
    public let visits: StoreVisitCountsWithHistoryListApiResponse
    public let favorite: FavoriteStoreWithTotalSubscribersCountApiResponse
}
