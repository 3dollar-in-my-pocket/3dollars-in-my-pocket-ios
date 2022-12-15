import UIKit

enum StoreType {
    case foodTruck
    case streetFood
    case unknown
    
    init(value: String) {
        switch value {
        case "BOSS_STORE":
            self = .foodTruck
            
        case "USER_STORE":
            self = .streetFood
            
        default:
            self = .unknown
        }
    }
    
    var title: String {
        switch self {
        case .foodTruck:
            return "푸드트럭"
            
        case .streetFood:
            return "길거리음식"
            
        case .unknown:
            return ""
        }
    }
    
    var themeColor: UIColor? {
        switch self {
        case .foodTruck:
            return R.color.green()
            
        case .streetFood:
            return R.color.pink()
            
        case .unknown:
            return nil
        }
    }
    
    var targetType: String {
        switch self {
        case .foodTruck:
            return "BOSS_STORE"
            
        case .streetFood:
            return "USER_STORE"
            
        case .unknown:
            return ""
        }
    }
    
    func toggle() -> Self {
        switch self {
        case .streetFood:
            return .foodTruck
            
        case .foodTruck:
            return .streetFood
            
        case .unknown:
            return .unknown
        }
    }
}
