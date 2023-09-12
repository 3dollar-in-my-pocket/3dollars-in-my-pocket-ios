import Foundation

import Model

struct StoreDetailSection: Hashable {
    enum StoreDetailSectionType {
        case overview
        case visit
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
    case visit
}
