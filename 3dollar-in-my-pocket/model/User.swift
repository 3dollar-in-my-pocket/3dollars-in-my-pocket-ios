import ObjectMapper

struct User: Mappable {
    
    var nickname: String?
    var socialId: String!
    var socialType: SocialType!
    
    init?(map: Map) {}
    
    init(nickname: String? = nil, socialId: String, socialType: String) {
        self.nickname = nickname
        self.socialId = socialId
        self.socialType = SocialType.init(rawValue: socialType)
    }
    
    mutating func mapping(map: Map) {
        self.nickname <- map["name"]
        self.socialId <- map["socialId"]
        self.socialType <- map["socialType"]
    }
    
    func toDict() -> [String: Any] {
        return ["name": self.nickname,
                "socialId": self.socialId,
                "socialType": self.socialType.rawValue]
    }
}

enum SocialType: String {
    case KAKAO = "KAKAO"
    case APPLE = "APPLE"
}
