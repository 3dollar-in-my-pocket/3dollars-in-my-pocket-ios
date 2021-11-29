import Foundation

struct Page<T: Decodable>: Decodable {
    
    let contents: [T]
    let nextCursor: Int
    
    
    enum CodingKeys: String, CodingKey {
        case contents
        case nextCursor
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.contents = try values.decodeIfPresent([T].self, forKey: .contents) ?? []
        self.nextCursor = try values.decodeIfPresent(Int.self, forKey: .nextCursor) ?? 0
    }
}
