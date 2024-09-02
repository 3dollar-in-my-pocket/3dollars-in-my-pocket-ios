import Foundation

public protocol VisitableStore {
    var storeName: String { get }
    var platformStoreCategories: [PlatformStoreCategory] { get }
    var storeLocation: Location? { get }
}

public extension VisitableStore {
    /// 카테고리들 나열된 문자열 ex.) #붕어빵 #땅콩과자 #호떡
    var categoriesString: String {
        if platformStoreCategories.count > 3 {
            let splitedCategories = platformStoreCategories[..<3]
            
            return splitedCategories.map { "#\($0.name)"}.joined(separator: " ")
        } else {
            return platformStoreCategories.map { "#\($0.name)"}.joined(separator: " ")
        }
    }
}
