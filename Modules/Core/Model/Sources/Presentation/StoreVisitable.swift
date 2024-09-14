import Foundation

public protocol VisitableStore {
    var storeName: String { get }
    var categories: [StoreFoodCategoryResponse] { get }
    var location: LocationResponse? { get }
}

public extension VisitableStore {
    /// 카테고리들 나열된 문자열 ex.) #붕어빵 #땅콩과자 #호떡
    var categoriesString: String {
        if categories.count > 3 {
            let splitedCategories = categories[..<3]
            
            return splitedCategories.map { "#\($0.name)"}.joined(separator: " ")
        } else {
            return categories.map { "#\($0.name)"}.joined(separator: " ")
        }
    }
}
