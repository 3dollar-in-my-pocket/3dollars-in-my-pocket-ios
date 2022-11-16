struct UserInfoResponse: Decodable {
    let medal: MedalResponse
    let name: String
    let socialType: String
    let userId: Int
    
    enum CodingKeys: String, CodingKey {
        case medal
        case name
        case socialType
        case userId
    }
    
    init() {
        self.name = ""
        self.socialType = ""
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
            String.self,
            forKey: .socialType
        ) ?? ""
        self.userId = try values.decodeIfPresent(Int.self, forKey: .userId) ?? -1
    }
}
