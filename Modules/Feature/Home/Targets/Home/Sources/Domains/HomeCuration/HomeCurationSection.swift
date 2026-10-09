import Foundation

import Model

enum HomeCurationSectionItem: Hashable {
    case carousel(HomeCurationCarouselViewData)
    case admobCard(HomeListAdmobCardResponse)

    var identifier: HomeCurationItemIdentifier {
        switch self {
        case .carousel(let carousel):
            return .carousel(carouselId: carousel.carouselId)
        case .admobCard(let card):
            return .admobCard(cardId: card.cardId)
        }
    }
}

enum HomeCurationItemIdentifier: Hashable {
    case carousel(carouselId: String)
    case admobCard(cardId: String)
}

struct HomeCurationCarouselViewData: Hashable {
    let carouselId: String
    let header: SDHeader
    let categories: [HomeCurationCategoryViewData]
    let selectedCategoryId: String
    let cards: [HomeCurationCard]
}

struct HomeCurationSelectedStore: Equatable {
    let storeId: Int
    let latitude: Double
    let longitude: Double
}

struct HomeCurationCategoryViewData: Hashable {
    let filter: HomeCurationCategoryFilter
    let isSelected: Bool

    var chip: SDChip {
        isSelected ? filter.selected : filter.unselected
    }
}
