import ObjectMapper

struct StoreCard: Mappable {
    var category: StoreCategory!
    var distance: Int!
    var id: Int!
    var latitude: Double!
    var longitude: Double!
    var storeName: String!
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        self.category <- map["category"]
        self.distance <- map["distance"]
        self.id <- map["id"]
        self.latitude <- map["latitude"]
        self.longitude <- map["longitude"]
        self.storeName <- map["storeName"]
    }
}

enum StoreCategory: String {
    case BUNGEOPPANG = "BUNGEOPPANG"
    case TAKOYAKI = "TAKOYAKI"
    case GYERANPPANG = "GYERANPPANG"
    case HOTTEOK = "HOTTEOK"
}
