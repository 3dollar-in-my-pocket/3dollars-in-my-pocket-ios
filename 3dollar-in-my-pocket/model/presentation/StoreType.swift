import UIKit

enum StoreType {
    case foodTruck
    case streetFood
    
    var title: String {
        switch self {
        case .foodTruck:
            return "푸드트럭"
            
        case .streetFood:
            return "길거리 음식"
        }
    }
    
    var themeColor: UIColor? {
        switch self {
        case .foodTruck:
            return R.color.pink()
            
        case .streetFood:
            return R.color.green()
        }
    }
}
