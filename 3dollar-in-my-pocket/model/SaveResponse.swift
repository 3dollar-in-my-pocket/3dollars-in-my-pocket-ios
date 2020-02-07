import ObjectMapper

struct SaveResponse: Mappable {
    var storeId: Int!
    
    
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        self.storeId <- map["storeId"]
    }
}
