import Foundation

public struct UserStorePatchRequestV3: Encodable {
    public let latitude: Double?
    public let longitude: Double?
    public let storeName: String?
    public let storeType: SalesType?
    public let appearanceDays: [AppearanceDay]?
    public let openingHours: StoreOpeningHours?
    public let paymentMethods: [PaymentMethod]?
    public var menus: [UserStoreMenuRequestV3]?
    
    public init(
        latitude: Double?,
        longitude: Double?,
        storeName: String?,
        storeType: SalesType?,
        appearanceDays: [AppearanceDay]?,
        openingHours: StoreOpeningHours?,
        paymentMethods: [PaymentMethod]?,
        menus: [UserStoreMenuRequestV3]?
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.storeName = storeName
        self.storeType = storeType
        self.appearanceDays = appearanceDays
        self.openingHours = openingHours
        self.paymentMethods = paymentMethods
        self.menus = menus
    }
}
