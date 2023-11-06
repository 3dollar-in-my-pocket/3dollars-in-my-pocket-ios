import Foundation

public struct StoreDetailOverview: Hashable {
    public let categories: [PlatformStoreCategory]
    public let repoterName: String
    public let storeName: String
    public let isNew: Bool
    public let totalVisitSuccessCount: Int
    public let reviewCount: Int
    public let distance: Int
    public let location: Location
    public let address: String
    public var isFavorited: Bool
    public var subscribersCount: Int
    public var isBossStore: Bool
    public var snsUrl: String?
    public var introduction: String?
}

extension StoreDetailOverview {
    /// 카테고리들 나열된 문자열 ex.) #붕어빵 #땅콩과자 #호떡
    public var categoriesString: String {
        if categories.count > 3 {
            let splitedCategories = categories[..<3]
            
            return splitedCategories.map { "#\($0.name)"}.joined(separator: " ")
        } else {
            return categories.map { "#\($0.name)"}.joined(separator: " ")
        }
    }
}

extension StoreDetailOverview: VisitableStore {
    public var storeLocation: Location? {
        return location
    }
}
