import Foundation

struct UserWithActivityResponse: Decodable {
    
    let activity: ActivityResponse
    let medalType: String // TODO: 실제 타입 들어오면 enum으로 변경 예정
    let name: String
    let socialType: SocialType
    let userId: Int
    
    enum CodingKeys: String, CodingKey {
        case activity
        case medalType
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
        self.medalType = try values.decodeIfPresent(String.self, forKey: .medalType) ?? ""
        self.name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.socialType = try values.decodeIfPresent(SocialType.self, forKey: .socialType) ?? .APPLE
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
