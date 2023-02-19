import RxDataSources

struct BookmarkViewerSectionModel {
    var items: [Item]
}

extension BookmarkViewerSectionModel: SectionModelType {
    typealias Item = StoreProtocol
    
    init(original: BookmarkViewerSectionModel, items: [Item]) {
        self = original
        self.items = items
    }
    
    init(stores: [StoreProtocol]) {
        self.items = stores
    }
}
