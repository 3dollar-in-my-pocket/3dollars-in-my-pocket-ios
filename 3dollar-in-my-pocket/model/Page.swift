import ObjectMapper

struct Page<T: Mappable>: Mappable {
    var content: [T]!
    var empty: Bool!
    var first: Bool!
    var last: Bool!
    var number: Int!
    var numberOfElements: Int!
    var size: Int!
    var totalElements: Int!
    var totalPages: Int!
    
    
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        self.content <- map["content"]
        self.empty <- map["empty"]
        self.first <- map["first"]
        self.last <- map["last"]
        self.number <- map["number"]
        self.numberOfElements <- map["numberOfElements"]
        self.size <- map["size"]
        self.totalElements <- map["totalElements"]
        self.totalPages <- map["totalPages"]
    }
}
