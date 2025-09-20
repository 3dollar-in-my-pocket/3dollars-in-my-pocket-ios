import Foundation

public struct UserStoreResponse: Decodable {
    public let storeId: Int
    public let isOwner: Bool
    public var name: String
    
    @available(*, deprecated, message: "salesTypeV2를 사용하세요.")
    public let salesType: SalesType?
    
    public var salesTypeV2: StoreSalesTypeResponse?
    public let rating: Double
    public var location: LocationResponse
    public var address: AddressResponse
    public var categories: [StoreFoodCategoryResponse]
    public var appearanceDays: [AppearanceDay]
    public var openingHours: StoreOpeningHours?
    public var paymentMethods: [PaymentMethod]
    
    @available(*, deprecated, message: "menusV2를 사용하세요.")
    public let menus: [UserStoreMenuResponse]
    
    public var menusV3: [UserStoreMenuResponseV3]
    public let isDeleted: Bool
    public let activitiesStatus: ActivitiesStatus
    public let createdAt: String
    public let updatedAt: String
}


public struct StoreSalesTypeResponse: Decodable {
    public var type: SalesType
    public let description: String
}

public struct UserStoreMenuResponseV3: Decodable {
    public let name: String
    public let price: Int?
    public let count: Int?
    public let description: String?
    public let category: StoreFoodCategoryResponse
}
