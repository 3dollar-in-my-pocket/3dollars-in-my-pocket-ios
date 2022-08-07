struct BossStoreMenu: Equatable {
    let imageUrl: String
    let name: String
    let price: Int
    
    init(response: BossStoreMenuResponse) {
        self.imageUrl = response.imageUrl
        self.name = response.name
        self.price = response.price
    }
}
