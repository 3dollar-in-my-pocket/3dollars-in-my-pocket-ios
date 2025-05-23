import Foundation

import Model

struct HomeCardSection: Hashable {
    public var items: [HomeCardSectionItem]
    
    public init(items: [HomeCardSectionItem]) {
        self.items = items
    }
}

enum HomeCardSectionItem: Hashable {
    case store(HomeStoreCardCellViewModel)
    case advertisement(HomeAdCardSectionResponse)
    case admob(HomeAdmobCardSectionResponse)
    case empty
}

extension HomeCardSectionItem {
    var store: HomeStoreCardCellViewModel? {
        switch self {
        case .store(let viewModel):
            return viewModel
        default:
            return nil
        }
    }
}
