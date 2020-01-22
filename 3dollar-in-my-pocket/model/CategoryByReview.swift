import ObjectMapper

struct CategoryByReview: Mappable {
    var storeList0: [StoreCard] = []
    var storeList1: [StoreCard] = []
    var storeList2: [StoreCard] = []
    var storeList3: [StoreCard] = []
    var storeList4: [StoreCard] = []
    
    
    init() { }
    
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        self.storeList0 <- map["storeList0"]
        self.storeList1 <- map["storeList1"]
        self.storeList2 <- map["storeList2"]
        self.storeList3 <- map["storeList3"]
        self.storeList4 <- map["storeList4"]
    }
}
