import Foundation

struct BossStoreDetailSection: Hashable {
    enum SectionType: Hashable {
        case verifiedBanner
        case overview
        case info
        case workday
        case feedbacks
        case coupons(BossStoreDetailCouponHeaderViewModel)
        case post
        case bridgeCarousel
        case review(BossStoreDetailReviewHeaderViewModel)
        case divider
    }

    var type: SectionType
    var items: [BossStoreDetailSectionItem]
}

extension BossStoreDetailSection {
    static func dividerSection(_ configuration: StoreDetailDividerCell.Configuration = .default) -> BossStoreDetailSection {
        return .init(type: .divider, items: [.divider(configuration)])
    }
}
