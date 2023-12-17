import Foundation

enum StoreViewType {
    case storeDetail
    case bossStoreDetail
    
    var title: String {
        switch self {
        case .storeDetail:
            return "유저 가게 상세화면"
            
        case .bossStoreDetail:
            return "사장님 가게 상세화면"
        }
    }
}
