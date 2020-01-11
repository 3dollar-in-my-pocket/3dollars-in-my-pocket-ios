import ObjectMapper

struct StoreCards: Mappable {
    var data: [StoreCard]?
    
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        self.data <- map["data"]
    }
}
