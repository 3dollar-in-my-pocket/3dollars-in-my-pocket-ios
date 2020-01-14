import ObjectMapper

struct Review: Mappable {
    var category: StoreCategory!
    var contents: String!
    var id: Int!
    var rating: Int!
    var user: User!
    
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        self.category <- map["category"]
        self.contents <- map["contents"]
        self.id <- map["id"]
        self.rating <- map["rating"]
        self.user <- map["user"]
    }
}
