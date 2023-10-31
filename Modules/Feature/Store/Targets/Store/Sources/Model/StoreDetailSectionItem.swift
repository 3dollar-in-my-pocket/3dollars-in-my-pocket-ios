import Foundation

import Model

enum StoreDetailSectionItem: Hashable {
    case overview(StoreDetailOverviewCellViewModel)
    case visit(StoreDetailVisit)
    case info(StoreDetailInfo)
    case menu(StoreDetailMenuCellViewModel)
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
    
    var menuCellViewModel: StoreDetailMenuCellViewModel? {
        if case .menu(let viewModel) = self {
            return viewModel
        } else {
            return nil
        }
    }
}

