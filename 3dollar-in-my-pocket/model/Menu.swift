import ObjectMapper

struct Menu: Mappable {
    var id: Int!
    var name: String!
    var price: Int!
    
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        self.id <- map["id"]
        self.name <- map["name"]
        self.price <- map["price"]
    }
}
