struct UserInfoResponse: Decodable {
    let medal: MedalResponse
    let name: String
    let socialType: SocialType
    let userId: Int
    
    enum CodingKeys: String, CodingKey {
        case medal
        case name
        case socialType
        case userId
    }
    
    
    init() {
        self.name = ""
        self.socialType = .KAKAO
        self.userId = -1
        self.medal = MedalResponse()
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.medal = try values.decodeIfPresent(
            MedalResponse.self,
            forKey: .medal
        ) ?? MedalResponse()
        self.name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.socialType = try values.decodeIfPresent(
            SocialType.self,
            forKey: .socialType
        ) ?? .KAKAO
        self.userId = try values.decodeIfPresent(Int.self, forKey: .userId) ?? -1
    }
}
