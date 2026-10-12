import Foundation

import Model

struct HomeListSection: Hashable {
    var items: [HomeListSectionItem]
}

enum HomeListSectionItem: Hashable {
    case basicCard(HomeListBasicCardResponse)
    case admobCard(HomeListAdmobCardResponse)
    case emptyCard(HomeListEmptyCardResponse)
}

struct HomeBottomSheetTabItem: Hashable {
    let tab: HomeBottomTab
    let isSelected: Bool
}
