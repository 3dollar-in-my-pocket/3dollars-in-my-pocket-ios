import Foundation

public struct UserStoreCreateRequest: Encodable {
    public let latitude: Double
    public let longitude: Double
    public let storeName: String
    public let storeType: UserStoreCreateRequest.StoreType?
    public let appearanceDays: [AppearanceDay]
    public let openingHours: UserStoreOpeningHoursRequest?
    public let paymentMethods: [PaymentMethod]
    public let menus: [UserStoreMenuV2Request]
    public let nonceToken: String
    
    public init(
        latitude: Double,
        longitude: Double,
        storeName: String,
        storeType: UserStoreCreateRequest.StoreType?,
        appearanceDays: [AppearanceDay],
        openingHours: UserStoreOpeningHoursRequest?,
        paymentMethods: [PaymentMethod],
        menus: [UserStoreMenuV2Request],
        nonceToken: String
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.storeName = storeName
        self.storeType = storeType
        self.appearanceDays = appearanceDays
        self.openingHours = openingHours
        self.paymentMethods = paymentMethods
        self.menus = menus
        self.nonceToken = nonceToken
    }
}

public extension UserStoreCreateRequest {
    enum StoreType: String, Encodable, Equatable {
        case road = "ROAD"
        case store = "STORE"
        case convenienceStore = "CONVENIENCE_STORE"
        case foodTruck = "FOOD_TRUCK"
    }
}
