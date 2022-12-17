import RxDataSources

struct MyPageSectionModel: Equatable {
    var items: [Item]
}

extension MyPageSectionModel: SectionModelType {
    typealias Item = SectionItemType
    
    enum SectionItemType: Equatable {
        case overview(User)
        case visitHistory(VisitHistory?)
        case bookmark(StoreProtocol?)
        
        static func == (
            lhs: MyPageSectionModel.SectionItemType,
            rhs: MyPageSectionModel.SectionItemType
        ) -> Bool {
            switch (lhs, rhs) {
            case (.overview(let userA), .overview(let userB)):
                return userA == userB
                
            case (.visitHistory(let visitHistoryA), .visitHistory(let visitHistoryB)):
                return visitHistoryA == visitHistoryB
                
            case (.bookmark(let storeA), .bookmark(let storeB)):
                if let storeA = storeA,
                   let storeB = storeB {
                    return storeA.id == storeB.id
                } else {
                    return false
                }
                
            default:
                return false
            }
        }
    }
    
    init(original: MyPageSectionModel, items: [SectionItemType]) {
        self = original
        self.items = items
    }
    
    init(user: User) {
        self.items = [.overview(user)]
    }
    
    init(visitHistories: [VisitHistory]) {
        if visitHistories.isEmpty {
            self.items = [.visitHistory(nil)]
        } else {
            self.items = visitHistories.map { .visitHistory($0) }
        }
    }
    
    init(bookmarks: [StoreProtocol]) {
        if bookmarks.isEmpty {
            self.items = [.bookmark(nil)]
        } else {
            self.items = bookmarks.map { .bookmark($0) }
        }
    }
}
