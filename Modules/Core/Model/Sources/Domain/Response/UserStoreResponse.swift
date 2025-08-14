import Foundation

public struct UserStoreResponse: Decodable {
    public let storeId: Int
    public let isOwner: Bool
    public let name: String
    
    @available(*, deprecated, message: "salesTypeV2를 사용하세요.")
    public let salesType: SalesType?
    
    public let salesTypeV2: StoreSalesTypeResponse?
    public let rating: Double
    public let location: LocationResponse
    public let address: AddressResponse
    public let categories: [StoreFoodCategoryResponse]
    public let appearanceDays: [AppearanceDay]
    public let openingHours: StoreOpeningHours?
    public let paymentMethods: [PaymentMethod]
    
    @available(*, deprecated, message: "menusV2를 사용하세요.")
    public let menus: [UserStoreMenuResponse]
    
    public var menusV3: [UserStoreMenuResponseV3]
    public let isDeleted: Bool
    public let activitiesStatus: ActivitiesStatus
    public let createdAt: String
    public let updatedAt: String
}


public struct StoreSalesTypeResponse: Decodable {
    public let type: SalesType
    public let description: String
}

public struct UserStoreMenuResponseV3: Decodable {
    public let name: String
    public let price: Int?
    public let count: Int?
    public let description: String?
    public let category: StoreFoodCategoryResponse
}
