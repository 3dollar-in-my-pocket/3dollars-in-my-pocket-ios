import Foundation

struct UserWithActivityResponse: Decodable {
    let activity: ActivityResponse
    let medal: MedalResponse
    let name: String
    let socialType: SocialType
    let userId: Int
    
    enum CodingKeys: String, CodingKey {
        case activity
        case medal
        case name
        case socialType
        case userId
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.activity = try values.decodeIfPresent(
            ActivityResponse.self,
            forKey: .activity
        ) ?? ActivityResponse()
        self.medal = try values.decodeIfPresent(
            MedalResponse.self,
            forKey: .medal
        ) ?? MedalResponse()
        self.name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.socialType = try values.decodeIfPresent(
            SocialType.self,
            forKey: .socialType
        ) ?? .APPLE
        self.userId = try values.decodeIfPresent(Int.self, forKey: .userId) ?? 0
    }
}

extension UserWithActivityResponse {
    
    struct ActivityResponse: Decodable {
        let medalsCounts: Int
        let reviewsCount: Int
        let storesCount: Int
        
        enum CodingKeys: String, CodingKey {
            case medalsCounts
            case reviewsCount
            case storesCount
        }
        
        init() {
            self.medalsCounts = 0
            self.reviewsCount = 0
            self.storesCount = 0
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            self.medalsCounts = try values.decodeIfPresent(Int.self, forKey: .medalsCounts) ?? 0
            self.reviewsCount = try values.decodeIfPresent(Int.self, forKey: .reviewsCount) ?? 0
            self.storesCount = try values.decodeIfPresent(Int.self, forKey: .storesCount) ?? 0
        }
    }
}
