import Foundation

import Model

enum StoreDetailSectionItem: Hashable {
    case overview(StoreDetailOverview)
    case visit(StoreDetailVisit)
    case info(StoreDetailInfo)
    case menu(StoreDetailMenuCellViewModel)
    case photo(StoreDetailPhoto)
    case rating(Double)
    case review(StoreDetailReview)
    case reviewMore(Int)
}

extension StoreDetailSectionItem {
    var histories: [StoreVisitHistory]? {
        if case .visit(let storeDetailVisit) = self {
            return storeDetailVisit.histories
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

