struct ReviewInfoResponse: Decodable {
    let contents: String
    let createdAt: String
    let rating: Int
    let reviewId: Int
    let storeId: Int
    
    enum CodingKeys: String, CodingKey {
        case contents
        case createdAt
        case rating
        case reviewId
        case storeId
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.contents = try values.decodeIfPresent(String.self, forKey: .contents) ?? ""
        self.createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
        self.rating = try values.decodeIfPresent(Int.self, forKey: .rating) ?? 0
        self.reviewId = try values.decodeIfPresent(Int.self, forKey: .reviewId) ?? 0
        self.storeId = try values.decodeIfPresent(Int.self, forKey: .storeId) ?? 0
    }
}
