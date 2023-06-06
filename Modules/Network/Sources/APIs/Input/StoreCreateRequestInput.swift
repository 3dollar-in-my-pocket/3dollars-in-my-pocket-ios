import Foundation

public struct StoreCreateRequestInput: Encodable {
    let latitude: Double
    let longitude: Double
    let storeName: String
    let storeType: String
    let appearanceDays: [String]
    let paymentMethods: [String]
    let menus: [StoreMenuRequestInput]
}
