import Foundation

import Model

enum BossStoreDetailSectionItem: Hashable {
    case overview(StoreDetailOverviewCellViewModel)
    case info(BossStoreInfoCellViewModel)
    case menuList(BossStoreMenuListCellViewModel)
    case emptyMenu
    case workday([BossStoreAppearanceDay])
    case feedbacks(BossStoreFeedbacksCellViewModel)
}
