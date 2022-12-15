protocol StoreProtocol {
    var id: String { get }
    var latitude: Double { get }
    var longitude: Double { get }
    var name: String { get }
    
    // TODO: 다른 네이밍이 필요합니다. StoreType을 사용하고 싶지만 Store 모델에 이미 사용중인 이름입니다.
    var storeCategory: StoreType { get }
}
