import Foundation

public struct EditStoreRequestInput: Encodable {
    public let latitude: Double
    public let longitude: Double
    public let storeName: String
    public let storeType: String?
    public let appearanceDays: [String]
    public let paymentMethods: [String]
    public let menus: [StoreMenuRequestInput]
    
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
