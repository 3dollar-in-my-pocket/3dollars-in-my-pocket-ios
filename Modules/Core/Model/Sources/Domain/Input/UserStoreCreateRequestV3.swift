import Foundation

public struct UserStoreCreateRequestV3: Encodable {
    public let latitude: Double
    public let longitude: Double
    public let storeName: String
    public let salesType: SalesType?
    public let appearanceDays: [AppearanceDay]
    public let openingHours: StoreOpeningHours?
    public let paymentMethods: [PaymentMethod]
    public let menus: [UserStoreMenuRequestV3]
    public let nonceToken: String
    
    public init(
        latitude: Double,
        longitude: Double,
        storeName: String,
        salesType: SalesType?,
        appearanceDays: [AppearanceDay],
        openingHours: StoreOpeningHours?,
        paymentMethods: [PaymentMethod],
        menus: [UserStoreMenuRequestV3],
        nonceToken: String
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.storeName = storeName
        self.salesType = salesType
        self.appearanceDays = appearanceDays
        self.openingHours = openingHours
        self.paymentMethods = paymentMethods
        self.menus = menus
        self.nonceToken = nonceToken
    }
}
