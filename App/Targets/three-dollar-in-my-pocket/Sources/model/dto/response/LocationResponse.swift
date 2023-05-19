struct LocationResponse: Decodable {
    let latitude: Double
    let longitude: Double
    
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
    
    init(
        latitude: Double = 0,
        longitude: Double = 0
    ) {
        self.latitude  = latitude
        self.longitude = longitude
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.latitude = try values.decodeIfPresent(Double.self, forKey: .latitude) ?? 0
        self.longitude = try values.decodeIfPresent(Double.self, forKey: .longitude) ?? 0
    }
}
