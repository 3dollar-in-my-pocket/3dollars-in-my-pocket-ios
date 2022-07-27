import Foundation

enum StoreCellType {
    case store(StoreProtocol)
    case advertisement(Advertisement)
    case empty
    
    var value: Any? {
        switch self {
        case .store(let store):
            return store
            
        case .advertisement(let advertisement):
            return advertisement
            
        case .empty:
            return nil
        }
    }
}

extension StoreCellType: Equatable {
    static func == (lhs: StoreCellType, rhs: StoreCellType) -> Bool {
        switch (lhs, rhs) {
        case (.store(let store1), .store(let store2)):
            return store1.id == store2.id
//            return store1.id == store2.storeId
//            && store1.visitHistory.isCertified == store2.visitHistory.isCertified
            
        case (.advertisement(let ad1), .advertisement(let ad2)):
            return ad1.id == ad2.id
            
        case (.empty, .empty):
            return true
            
        default:
            return false
        }
    }
}
