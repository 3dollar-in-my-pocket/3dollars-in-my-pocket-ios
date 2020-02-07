import ObjectMapper

struct Menu: Mappable {
    var id: Int!
    var name: String!
    var price: String?
    
    
    init?(map: Map) { }
    
    init(name: String, price: String? = nil) {
        self.name = name
        self.price = price
    }
    
    mutating func mapping(map: Map) {
        self.id <- map["id"]
        self.name <- map["name"]
        self.price <- map["price"]
    }
    
    mutating func setPrice(price: String) {
        self.price = price
    }
    
    func toDict() -> [String: Any] {
        return ["name": name, "price": price]
    }
}
