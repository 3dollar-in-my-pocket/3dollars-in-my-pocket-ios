import Foundation

public struct StoreDetailResponse: Decodable {
    public let storeId: String
    public let storeType: StoreType
    public let name: String
    public let rating: Double
    public let owner: WriterResponse?
    public let isOwner: Bool
    public let location: LocationResponse?
    public let address: AddressResponse
    public let distanceM: Double
    public let categories: [StoreFoodCategoryResponse]
    public let activitiesStatus: ActivitiesStatus
    public let openStatus: StoreOpenStatus?
    public let metadata: StoreMetaadataResponse?
    public let createdAt: String?
    public let updatedAt: String?
}

public extension StoreDetailResponse {
    var categoriesString: String {
        if categories.count > 3 {
            let splitedCategories = categories[..<3]
            
            return splitedCategories.map { "#\($0.name)"}.joined(separator: " ")
        } else {
            return categories.map { "#\($0.name)"}.joined(separator: " ")
        }
    }
}

public struct WriterResponse: Decodable {
    public let writerId: String
    public let writerType: WriterType
    public let name: String
}


public enum WriterType: String, Decodable {
    case store = "STORE"
    case user = "USER"
}

public struct StoreMetaadataResponse: Decodable {
    public let reviewCount: Int
}
