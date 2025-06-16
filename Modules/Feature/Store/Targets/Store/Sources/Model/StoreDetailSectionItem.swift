import Foundation

import Model

enum StoreDetailSectionItem: Hashable {
    case baseInfo(StoreDetailBaseInfoCellViewModel)
    case accountNumber(StoreDetailAccountNumberCellViewModel)
    case actionBar(StoreDetailActionBarCellViewModel)
    case admob(StoreDetailAdmobCellViewModel)
    case categorizedMenu(StoreDetailCategorizedMenusCellViewModel)
    case imageMenu(StoreDetailImageMenuCellViewModel)
    case images(StoreDetailImageCellViewModel)
    case map(StoreDetailMapCellViewModel)
    case news(StoreDetailNewsCellViewModel)
    case openingDays(StoreDetailOpeningDaysCellViewModel)
    case overview(StoreDetailOverviewCellViewModel)
    
    case visit(StoreDetailVisit)
    case rating(Double)
    case review(StoreDetailReview)
    case reviewMore(Int)
    case reviewEmpty
    case filteredReview(StoreDetailReview)
}

extension StoreDetailSectionItem {
    var historyContentsCount: Int? {
        if case .visit(let storeDetailVisit) = self {
            return storeDetailVisit.histories.count
        } else {
            return nil
        }
    }
}

