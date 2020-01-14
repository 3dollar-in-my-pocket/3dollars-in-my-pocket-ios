import ObjectMapper


struct Store: Mappable {
    var category: StoreCategory!
    var id: Int!
    var images: [Image]!
    var latitude: Double!
    var longitude: Double!
    var menus: [Menu]!
    var reviews: [Review]!
    var storeName: String!
    var repoter: User!
    
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        self.category <- map["category"]
        self.id <- map["id"]
        self.images <- map["images"]
        self.latitude <- map["latitude"]
        self.longitude <- map["longitude"]
        self.menus <- map["menu"]
        self.reviews <- map["review"]
        self.storeName <- map["storeName"]
        self.repoter <- map["user"]
    }
}
