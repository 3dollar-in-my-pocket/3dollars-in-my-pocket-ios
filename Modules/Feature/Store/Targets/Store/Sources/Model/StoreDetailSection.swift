import Foundation

import Model

struct StoreDetailSection: Hashable {
    enum StoreDetailSectionType {
        case overview
        case visit
        case info
    }
    
    var type: StoreDetailSectionType
    var header: StoreDetailSectionHeader?
    var items: [StoreDetailSectionItem]
}

struct StoreDetailSectionHeader: Hashable {
    let title: String
    let description: String?
    let value: String?
    let buttonTitle: String?
}

enum StoreDetailSectionItem: Hashable {
    case overview(StoreDetailOverview)
    case visit(StoreDetailVisit)
    case info(StoreDetailInfo)
    case menu(StoreDetailMenuCellViewModel)
    
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
