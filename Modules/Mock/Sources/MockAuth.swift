import Foundation

public struct MockAuth: Decodable {
    public let token: String
    public let userId: Int
    
    public init(token: String, userId: Int) {
        self.token = token
        self.userId = userId
    }
    
    enum CodingKeys: CodingKey {
        case token
        case userId
        case data
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let data = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        
        
        self.token = try data.decode(String.self, forKey: .token)
        self.userId = try data.decode(Int.self, forKey: .userId)
    }
}
