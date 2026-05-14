import Foundation

import Model

struct HomeListSection: Hashable {
    var items: [HomeListSectionItem]

    init(items: [HomeListSectionItem]) {
        self.items = items
    }
}

enum HomeListSectionItem: Hashable {
    case basicCard(HomeListBasicCardResponse)
    case admobCard(HomeListAdmobCardResponse)
    case emptyCard(HomeListEmptyCardResponse)
}
