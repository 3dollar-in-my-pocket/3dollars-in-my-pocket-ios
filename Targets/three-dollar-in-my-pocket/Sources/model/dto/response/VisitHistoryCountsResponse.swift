import Foundation

struct VisitHistoryCountsResponse: Decodable {
    let existsCounts: Int
    let isCertified: Bool
    let notExistsCounts: Int
    
    enum CodingKeys: String, CodingKey {
        case existsCounts
        case isCertified
        case notExistsCounts
    }
    
    init() {
        self.existsCounts = 0
        self.isCertified = false
        self.notExistsCounts = 0
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.existsCounts = try values.decodeIfPresent(Int.self, forKey: .existsCounts) ?? 0
        self.isCertified = try values.decodeIfPresent(Bool.self, forKey: .isCertified) ?? false
        self.notExistsCounts = try values.decodeIfPresent(Int.self, forKey: .notExistsCounts) ?? 0
    }
}
