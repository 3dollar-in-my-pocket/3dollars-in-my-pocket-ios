import Foundation

public struct StoreMenuRequestInput: Encodable {
    let name: String
    let price: String
    let category: [String]
}
