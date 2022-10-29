import UIKit

enum StoreType {
    case foodTruck
    case streetFood
    
    var title: String {
        switch self {
        case .foodTruck:
            return "푸드트럭"
            
        case .streetFood:
            return "길거리음식"
        }
    }
    
    var themeColor: UIColor? {
        switch self {
        case .foodTruck:
            return R.color.green()
            
        case .streetFood:
            return R.color.pink()
        }
    }
    
    var targetType: String {
        switch self {
        case .foodTruck:
            return "BOSS_STORE"
            
        case .streetFood:
            return "USER_STORE"
        }
    }
    
    func toggle() -> Self {
        switch self {
        case .streetFood:
            return .foodTruck
            
        case .foodTruck:
            return .streetFood
        }
    }
}
