struct BossStoreCategoryResponse: Decodable {
    let categoryId: String
    let imageUrl: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case categoryId
        case imageUrl
        case name
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.categoryId = try values.decodeIfPresent(
            String.self,
            forKey: .categoryId
        ) ?? ""
        self.imageUrl = try values.decodeIfPresent(String.self, forKey: .imageUrl) ?? ""
        self.name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
    }
}
