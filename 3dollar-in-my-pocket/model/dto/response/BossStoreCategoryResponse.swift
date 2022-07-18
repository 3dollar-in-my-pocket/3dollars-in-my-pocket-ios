struct BossStoreCategoryResponse: Decodable {
    let categoryId: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case categoryId
        case name
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.categoryId = try values.decodeIfPresent(
            String.self,
            forKey: .categoryId
        ) ?? ""
        self.name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
    }
}
