import Foundation

public struct StoreCreateRequestInput: Encodable {
    public let latitude: Double
    public let longitude: Double
    public let storeName: String
    public let storeType: String?
    public let appearanceDays: [AppearanceDay]
    public let openingHours: StoreOpeningHoursRequest?
    public let paymentMethods: [PaymentMethod]
    public let menus: [StoreMenuRequest]
    
    public init(
        latitude: Double,
        longitude: Double,
        storeName: String,
        storeType: String?,
        appearanceDays: [AppearanceDay],
        openingHours: StoreOpeningHoursRequest?,
        paymentMethods: [PaymentMethod],
        menus: [StoreMenuRequest]
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
