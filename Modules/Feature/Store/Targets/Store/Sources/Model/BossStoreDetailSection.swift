import Foundation

struct BossStoreDetailSection: Hashable {
    enum SectionType: Hashable {
        case overview
        case info
        case workday
        case feedbacks
        case coupons(BossStoreDetailCouponHeaderViewModel)
        case post
        case review(BossStoreDetailReviewHeaderViewModel)
    }

    var type: SectionType
    var items: [BossStoreDetailSectionItem]
}
