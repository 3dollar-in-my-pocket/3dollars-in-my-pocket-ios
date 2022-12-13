import RxDataSources

struct BookmarkListSectionModel: Equatable {
    var items: [Item]
}

extension BookmarkListSectionModel: SectionModelType {
    typealias Item = BookmarkListItemType
    
    enum BookmarkListItemType: Equatable {
        case overview(BookmarkFolder)
        case bookmarkStore(StoreProtocol)
        
        static func == (
            lhs: BookmarkListSectionModel.BookmarkListItemType,
            rhs: BookmarkListSectionModel.BookmarkListItemType
        ) -> Bool {
            switch (lhs, rhs) {
            case (.overview(let bookmarkFolder1), .overview(let bookmarkFolder2)):
                return bookmarkFolder1.folderId == bookmarkFolder2.folderId
                
            case (.bookmarkStore(let store1), .bookmarkStore(let store2)):
                return store1.id == store2.id
                
            default:
                return false
            }
        }
    }
    
    init(original: BookmarkListSectionModel, items: [BookmarkListItemType]) {
        self = original
        self.items = items
    }
    
    init(overview: BookmarkFolder) {
        self.items = [.overview(overview)]
    }
    
    init(stores: BookmarkFolder) {
        self.items = stores.bookmarks.map { .bookmarkStore($0) }
    }
}
