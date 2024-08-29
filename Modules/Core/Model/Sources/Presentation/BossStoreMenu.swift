import Foundation

public struct BossStoreMenu {
    public let name: String
    public let price: Int
    public let imageUrl: String?
    
    public init(response: BossStoreMenuResponse) {
        self.name = response.name
        self.price = response.price
        self.imageUrl = response.imageUrl
    }
}
