import Foundation

import Model

struct ReviewListSection: Hashable {
    enum ReviewListSectionType: Hashable {
        case list
    }
    
    var type: ReviewListSectionType
    var items: [ReviewListSectionItem]
}
