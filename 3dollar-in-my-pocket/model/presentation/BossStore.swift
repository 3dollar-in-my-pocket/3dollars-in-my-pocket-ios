struct BossStore: StoreProtocol {
    let id: String
    let categories: [Categorizable]
    let distance: Int
    let location: Location?
//    let menus:
    let name: String
    let openingTime: String?
    let status: OpenStatus
    
    init(response: BossStoreAroundInfoResponse) {
        self.id = response.bossStoreId
        self.categories = response.categories.map(FoodTruckCategory.init(response: ))
        self.distance = response.distance
        self.location = Location(response: response.location)
        self.name = response.name
        self.openingTime = response.openStatus.openStartDateTime
        self.status = OpenStatus(response: response.openStatus.status)
    }
}
