import Foundation

import Model

enum BossStoreDetailSectionItem: Hashable {
    case overview(StoreDetailOverviewCellViewModel)
    case info(BossStoreInfoCellViewModel)
    case menuList(BossStoreMenuListCellViewModel)
    case emptyMenu
    case coupon(BossStoreCouponViewModel)
    case workday([BossStoreAppearanceDay])
    case post(BossStorePostCellViewModel)
    case reviewRating(rating: Double)
    case reviewEmpty
    case reviewMore(totalCount: Int)
    case review(ReviewListCellViewModel)
    case reviewFeedbackSummary(BossStoreDetailReviewFeedbackSummaryCellViewModel)
    case filteredReview(StoreDetailReview)
}
