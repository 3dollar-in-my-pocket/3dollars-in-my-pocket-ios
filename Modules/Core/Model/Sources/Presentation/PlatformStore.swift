public struct PlatformStore: Hashable {
    public let type: StoreType
    public let id: String
    public let latitude: Double
    public let longitude: Double
    public let name: String
    public let storeCategory: StoreType
    public let categories: [PlatformStoreCategory]

    public init(response: StoreResponse) {
        self.type = response.storeType
        self.id = response.storeId
        self.latitude = 0
        self.longitude = 0
        self.name = response.storeName
        self.storeCategory = response.storeType
        self.categories = response.categories.map(PlatformStoreCategory.init(response:))
    }
}

public extension PlatformStore {
    var categoriesString: String {
        return self.categories.map { "#\($0.name)" }.joined(separator: " ")
    }
}
