import Foundation

import Model

enum BossStoreDetailSectionItem: Hashable {
    case overview(StoreDetailOverviewCellViewModel)
    case info(BossStoreInfoCellViewModel)
    case menuList(BossStoreMenuListCellViewModel)
    case emptyMenu
    case workday([BossStoreAppearanceDay])
    case feedbacks(BossStoreFeedbacksCellViewModel)
    case post(BossStorePostCellViewModel)
    case reviewRating(rating: Double)
    case reviewEmpty
    case reviewMore(totalCount: Int)
    case review(StoreDetailReview)
    case reviewFeedbackSummary(BossStoreDetailReviewFeedbackSummaryCellViewModel)
}
