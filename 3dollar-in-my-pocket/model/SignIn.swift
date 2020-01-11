import ObjectMapper

struct SignIn: Mappable {
    var token: String!
    var id: Int!
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        self.token <- map["token"]
        self.id <- map["userId"]
    }
}
