import ObjectMapper

struct Image: Mappable {
    var id: Int!
    var url: String!
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        self.id <- map["id"]
        self.url <- map["url"]
    }
    
}
