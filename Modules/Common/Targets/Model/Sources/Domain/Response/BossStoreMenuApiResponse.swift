import Foundation

public struct BossStoreMenuApiResponse: Decodable {
    public let name: String
    public let price: Int
    public let imageUrl: String?
}
