import Foundation

public struct StoreCreateRequestInput: Encodable {
    public let latitude: Double
    public let longitude: Double
    public let storeName: String
    public let storeType: String?
    public let appearanceDaysV2: [StoreAppearanceDayApiRequest]
    public let paymentMethods: [String]
    public let menus: [StoreMenuRequestInput]
    
    public init(
        latitude: Double,
        longitude: Double,
        storeName: String,
        storeType: String?,
        appearanceDaysV2: [StoreAppearanceDayApiRequest],
        paymentMethods: [String],
        menus: [StoreMenuRequestInput]
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.storeName = storeName
        self.storeType = storeType
        self.appearanceDaysV2 = appearanceDaysV2
        self.paymentMethods = paymentMethods
        self.menus = menus
    }
}
