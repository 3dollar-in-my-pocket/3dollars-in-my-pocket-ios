import Foundation

public struct StoreApiResponse: Decodable {
    public let storeType: StoreType
    public let storeId: String
    public let account: AccountResponse?
    public let storeName: String
    public let address: AddressResponse?
    public let location: LocationResponse?
    public let categories: [PlatformStoreCategoryResponse]
    public let isDeleted: Bool
    public let createdAt: String?
    public let updatedAt: String?
}

extension StoreApiResponse: Hashable, Equatable {
    public static func == (lhs: StoreApiResponse, rhs: StoreApiResponse) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(storeId)
        hasher.combine(storeName)
        hasher.combine(location)
    }
}

public extension StoreApiResponse {
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
