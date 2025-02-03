import Foundation

public struct BossStoreDetailResponse: Decodable {
    public let store: BossStoreResponse
    public let distanceM: Int
    public let openStatus: StoreOpenResponse
    public let favorite: StoreFavoriteResponse
    public let feedbacks: [FeedbackCountWithRatioResponse]
    // 서버 수정 필요
    public let newsPosts: ContentsWithCursorWithTotalCountResponse<PostResponse>
    public let tags: StoreTagResponse
    public let reviews: ContentsWithCursorWithTotalCountResponse<StoreReviewWithWriterResponse>
}
