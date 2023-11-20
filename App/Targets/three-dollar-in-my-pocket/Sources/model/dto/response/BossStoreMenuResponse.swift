struct BossStoreMenuResponse: Decodable {
    let imageUrl: String
    let name: String
    let price: Int
    
    enum CodingKeys: String, CodingKey {
        case imageUrl
        case name
        case price
    }
    
    init(
        imageUrl: String = "",
        name: String = "",
        price: Int = 0
    ) {
        self.imageUrl = imageUrl
        self.name = name
        self.price = price
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.imageUrl = try values.decodeIfPresent(String.self, forKey: .imageUrl) ?? ""
        self.name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.price = try values.decodeIfPresent(Int.self, forKey: .price) ?? 0
    }
}
