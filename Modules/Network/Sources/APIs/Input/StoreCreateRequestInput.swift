import Foundation

public struct StoreCreateRequestInput: Encodable {
    let latitude: Double
    let longitude: Double
    let storeName: String
    let storeType: String?
    let appearanceDays: [String]
    let paymentMethods: [String]
    let menus: [StoreMenuRequestInput]
    
    public init(
        latitude: Double,
        longitude: Double,
        storeName: String,
        storeType: String?,
        appearanceDays: [String],
        paymentMethods: [String],
        menus: [StoreMenuRequestInput]
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.storeName = storeName
        self.storeType = storeType
        self.appearanceDays = appearanceDays
        self.paymentMethods = paymentMethods
        self.menus = menus
    }
}
