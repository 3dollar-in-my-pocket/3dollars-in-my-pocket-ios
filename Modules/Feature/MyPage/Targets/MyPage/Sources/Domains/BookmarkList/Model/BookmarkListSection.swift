import Foundation

import Model

struct BookmarkListSection: Hashable {
    enum SectionType: Hashable {
        case overview
        case storeList(BookmarkSectionHeaderViewModel)
    }
    
    var type: SectionType
    var items: [BookmarkListSectionItem]
}


enum BookmarkListSectionItem: Hashable {
    case overview(name: String, introduction: String?)
    case store(BookmarkStoreCellViewModel)
}
