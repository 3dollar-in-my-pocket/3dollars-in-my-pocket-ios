import Foundation

public struct StoreResponse: Decodable {
    public let storeType: StoreType
    public let storeId: String
    public let isOwner: Bool
    public let account: AccountKey?
    public let storeName: String
    public let address: AddressResponse?
    public let location: LocationResponse?
    public let categories: [StoreFoodCategoryResponse]
    public let isDeleted: Bool
    public let activitiesStatus: ActivitiesStatus
    public let createdAt: String?
    public let updatedAt: String?
}

extension StoreResponse: Hashable, Equatable {
    public static func == (lhs: StoreResponse, rhs: StoreResponse) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(storeId)
        hasher.combine(storeName)
        hasher.combine(location)
    }
}

public extension StoreResponse {
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


// Deprecated될 것
extension StoreResponse: VisitableStore {
    public var platformStoreCategories: [PlatformStoreCategory] {
        return categories.map { PlatformStoreCategory(response: $0) }
    }
    
    public var storeLocation: Location? {
        if let location {
            return Location(response: location)
        } else {
            return nil
        }
    }
}
