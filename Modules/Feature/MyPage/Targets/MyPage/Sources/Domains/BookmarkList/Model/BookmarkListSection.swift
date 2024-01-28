import Foundation

import Model

struct BookmarkListSection: Hashable {
    enum SectionType: Hashable {
        case overview
        case storeList(BookmarkSectionHeaderViewModel)
        case empty
    }
    
    var type: SectionType
    var items: [BookmarkListSectionItem]
}


enum BookmarkListSectionItem: Hashable {
    case overview(name: String, introduction: String?)
    case store(BookmarkStoreCellViewModel)
    case empty
}
