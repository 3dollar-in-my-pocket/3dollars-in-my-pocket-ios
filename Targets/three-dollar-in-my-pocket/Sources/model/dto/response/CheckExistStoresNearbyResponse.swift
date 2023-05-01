import Foundation

struct CheckExistStoresNearbyResponse: Decodable {
    let isExists: Bool
    
    enum CodingKeys: String, CodingKey {
        case isExists
    }
    
    init() {
        self.isExists = false
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.isExists = try values.decodeIfPresent(Bool.self, forKey: .isExists) ?? false
    }
}
