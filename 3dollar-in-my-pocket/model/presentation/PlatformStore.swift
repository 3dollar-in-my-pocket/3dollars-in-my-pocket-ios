struct PlatformStore: StoreProtocol {
    let id: String
    let latitude: Double
    let longitude: Double
    let name: String
    let storeCategory: StoreType
    let categories: [PlatformStoreCategory]
    
    init(response: PlatformStoreResponse) {
        self.id = response.storeId
        self.latitude = 0
        self.longitude = 0
        self.name = response.storeName
        self.storeCategory = StoreType(value: response.storeType)
        self.categories = response.categories.map(PlatformStoreCategory.init(response:))
    }
}

extension PlatformStore {
    var categoriesString: String {
        return self.categories.map { "#\($0.name)" }.joined(separator: " ")
    }
}
