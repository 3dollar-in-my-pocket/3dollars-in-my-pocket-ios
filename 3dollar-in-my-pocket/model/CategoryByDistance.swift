import ObjectMapper

struct CategoryByDistance: Mappable {
    var storeList50: [StoreCard] = []
    var storeList100: [StoreCard] = []
    var storeList500: [StoreCard] = []
    var storeList1000: [StoreCard] = []
    var indexList: [Int] = []
    
    init() { }
    
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        self.storeList50 <- map["storeList50"]
        self.storeList100 <- map["storeList100"]
        self.storeList500 <- map["storeList500"]
        self.storeList1000 <- map["storeList1000"]
    }
}
