import Foundation

public struct BossStoreWithDetailApiResponse: Decodable {
    public let store: BossStoreDetailApiResponse
    public let distanceM: Int
    public let openStatus: StoreOpenResponse
    public let favorite: FavoriteStoreWithTotalSubscribersCountApiResponse
    public let feedbacks: [FeedbackCountWithRatioResponse]
    // 서버 수정 필요
    public let newsPosts: ContentsWithCursorWithTotalCountResponse<PostApiResponse>
    public let tags: PlatformStoreTagApiResponse
}
