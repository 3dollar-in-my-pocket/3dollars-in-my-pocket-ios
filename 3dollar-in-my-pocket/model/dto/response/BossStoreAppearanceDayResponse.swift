struct BossStoreAppearanceDayResponse: Decodable {
    let dayOfTheWeek: String
    let locationDescription: String
    let openingHours: TimeIntervalResponse
    
    enum CodingKeys: String, CodingKey {
        case dayOfTheWeek
        case locationDescription
        case openingHours
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.dayOfTheWeek = try values.decodeIfPresent(
            String.self,
            forKey: .dayOfTheWeek
        ) ?? ""
        self.locationDescription = try values.decodeIfPresent(
            String.self,
            forKey: .locationDescription
        ) ?? ""
        self.openingHours = try values.decodeIfPresent(
            TimeIntervalResponse.self,
            forKey: .openingHours
        ) ?? TimeIntervalResponse()
    }
    
    init() {
        self.dayOfTheWeek = ""
        self.locationDescription = ""
        self.openingHours = TimeIntervalResponse()
    }
}
