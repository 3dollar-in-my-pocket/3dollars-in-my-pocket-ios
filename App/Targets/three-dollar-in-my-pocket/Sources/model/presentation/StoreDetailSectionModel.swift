import RxDataSources

struct StoreDetailSectionModel: Equatable {
    var items: [Item]
}

extension StoreDetailSectionModel: SectionModelType {
    typealias Item = StoreDetailItemType
    
    enum StoreDetailItemType: Equatable {
        case overView(Store)
        case visitHistory(VisitOverview)
        case info(Store)
        case menu(Store)
        case photo(Store)
        case advertisement
        case reivew(review: Review, userId: Int)
    }
    
    init(original: StoreDetailSectionModel, items: [Item]) {
        self = original
        self.items = items
    }
    
    init(overView store: Store) {
        self.items = [.overView(store)]
    }
    
    init(visitOverview: VisitOverview) {
        self.items = [.visitHistory(visitOverview)]
    }
    
    init(info store: Store) {
        self.items = [.info(store)]
    }
    
    init(menu store: Store) {
        self.items = [.menu(store)]
    }
    
    init(photo store: Store) {
        if store.images.isEmpty {
            self.items = [.photo(Store())]
        } else if store.images.count <= 4 {
            self.items = store.images.map { _ in return StoreDetailItemType.photo(store) }
        } else {
            self.items = store.images[..<4].map { _ in return StoreDetailItemType.photo(store) }
        }
    }
    
    init(review store: Store, userId: Int) {
        self.items = [.advertisement] + store.reviews.map {
            StoreDetailItemType.reivew(review: $0, userId: userId)
        }
    }
}
