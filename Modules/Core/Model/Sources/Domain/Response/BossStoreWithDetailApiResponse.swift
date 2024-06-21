import Foundation

public struct BossStoreWithDetailApiResponse: Decodable {
    public let store: BossStoreDetailApiResponse
    public let distanceM: Int
    public let openStatus: StoreOpenResponse
    public let favorite: FavoriteStoreWithTotalSubscribersCountApiResponse
    public let feedbacks: [FeedbackCountWithRatioResponse]
    public let newPosts: ContentsWithCursorWithTotalCountResponse<PostApiResponse>
    public let tags: PlatformStoreTagApiResponse
}
