import ObjectMapper

struct Review: Mappable {
    var category: StoreCategory!
    var contents: String!
    var id: Int!
    var rating: Int!
    var user: User!
    var storeId: Int!
    
    
    init(rating: Int, contents: String) {
        self.rating = rating
        self.contents = contents
    }
    
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        self.category <- map["category"]
        self.contents <- map["contents"]
        self.id <- map["id"]
        self.rating <- map["rating"]
        self.user <- map["user"]
        self.storeId <- map["storeId"]
    }
}
