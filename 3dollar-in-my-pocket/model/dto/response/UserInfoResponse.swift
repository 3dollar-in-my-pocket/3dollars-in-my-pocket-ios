struct UserInfoResponse: Decodable {
    let device: DeviceInfoResponse
    let medal: MedalResponse
    let name: String
    let socialType: String
    let userId: Int
    let marketingConsent: String
    
    enum CodingKeys: String, CodingKey {
        case device
        case medal
        case name
        case socialType
        case userId
        case marketingConsent
    }
    
    init() {
        self.name = ""
        self.socialType = ""
        self.userId = -1
        self.medal = MedalResponse()
        self.device = DeviceInfoResponse()
        self.marketingConsent = ""
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.medal = try values.decodeIfPresent(
            MedalResponse.self,
            forKey: .medal
        ) ?? MedalResponse()
        self.device = try values.decodeIfPresent(
            DeviceInfoResponse.self,
            forKey: .device
        ) ?? DeviceInfoResponse()
        self.name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.socialType = try values.decodeIfPresent(
            String.self,
            forKey: .socialType
        ) ?? ""
        self.userId = try values.decodeIfPresent(Int.self, forKey: .userId) ?? -1
        self.marketingConsent = try values.decodeIfPresent(
            String.self,
            forKey: .marketingConsent
        ) ?? ""
    }
}
