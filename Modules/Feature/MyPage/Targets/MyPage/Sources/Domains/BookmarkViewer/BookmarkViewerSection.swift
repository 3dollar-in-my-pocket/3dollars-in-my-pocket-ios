import Foundation

import Model

struct BookmarkViewerSection: Hashable {
    enum SectionType: Hashable {
        case overview
        case storeList(count: Int)
    }
    
    var type: SectionType
    var items: [BookmarkViewerSectionItem]
}

enum BookmarkViewerSectionItem: Hashable {
    case overview(BookmarkViewerOverviewCell.UIModel)
    case store(StoreResponse)
}
