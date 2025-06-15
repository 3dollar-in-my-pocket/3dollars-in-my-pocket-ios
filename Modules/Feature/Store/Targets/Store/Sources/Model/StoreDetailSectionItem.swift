import Foundation

import Model

enum StoreDetailSectionItem: Hashable {
    case overview(StoreDetailOverviewCellViewModel)
    case accountNumber(StoreDetailAccountNumberCellViewModel)
    case admob(StoreDetailAdmobCellViewModel)
    case categorizedMenu(StoreDetailCategorizedMenusCellViewModel)
    
    case visit(StoreDetailVisit)
    case info(StoreDetailInfo)
    
    case photo(StoreDetailPhoto)
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

