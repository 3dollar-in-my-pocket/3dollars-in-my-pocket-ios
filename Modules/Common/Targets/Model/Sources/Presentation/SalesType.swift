import Foundation

public enum SalesType: String, Hashable {
    case road = "ROAD"
    case store = "STORE"
    case convenienceStore = "CONVENIENCE_STORE"
    case unknown
    
    init?(value: String?) {
        if let value {
            self = SalesType(rawValue: value) ??  .unknown
        } else {
            return nil
        }
    }
}
