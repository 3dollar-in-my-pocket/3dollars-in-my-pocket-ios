import Foundation

public struct BossStoreMenuResponse: Decodable {
    public let name: String
    public let price: Int
    public let imageUrl: String?
}
