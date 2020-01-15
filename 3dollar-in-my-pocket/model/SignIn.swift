import ObjectMapper

struct SignIn: Mappable {
    var token: String!
    var id: Int!
    var state: Bool! // 닉네임까지 입력해서 완벽하게 가입했는지 판별하는 플래그
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        self.token <- map["token"]
        self.id <- map["userId"]
        self.state <- map["state"]
    }
}
