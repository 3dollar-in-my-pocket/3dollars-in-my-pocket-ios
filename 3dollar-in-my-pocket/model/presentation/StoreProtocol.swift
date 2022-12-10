protocol StoreProtocol {
    var id: String { get }
    var latitude: Double { get }
    var longitude: Double { get }
    var name: String { get }
    var storeCategory: StoreType { get }
}
