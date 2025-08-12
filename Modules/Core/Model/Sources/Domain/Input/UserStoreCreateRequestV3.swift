import Foundation

public struct UserStoreCreateRequestV3: Encodable {
    public let latitude: Double
    public let longitude: Double
    public let storeName: String
    public let storeType: UserStoreCreateRequestV3.StoreType?
    public let appearanceDays: [AppearanceDay]
    public let openingHours: StoreOpeningHours?
    public let paymentMethods: [PaymentMethod]
    public let menus: [UserStoreMenuRequestV3]
    public let nonceToken: String
    
    public init(
        latitude: Double,
        longitude: Double,
        storeName: String,
        storeType: UserStoreCreateRequestV3.StoreType?,
        appearanceDays: [AppearanceDay],
        openingHours: StoreOpeningHours?,
        paymentMethods: [PaymentMethod],
        menus: [UserStoreMenuRequestV3],
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

public extension UserStoreCreateRequestV3 {
    enum StoreType: String, Encodable, Equatable {
        case road = "ROAD"
        case store = "STORE"
        case convenienceStore = "CONVENIENCE_STORE"
        case foodTruck = "FOOD_TRUCK"
        case unknown
        
        public init(from decoder: Decoder) throws {
            self = try StoreType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
        }
    }
}
