struct TimeIntervalResponse: Decodable {
    let endTime: LocalTime
    let startTime: LocalTime
    
    enum CodingKeys: String, CodingKey {
        case endTime
        case startTime
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.endTime = try values.decodeIfPresent(
            LocalTime.self,
            forKey: .endTime
        ) ?? LocalTime()
        self.startTime = try values.decodeIfPresent(
            LocalTime.self,
            forKey: .startTime
        ) ?? LocalTime()
    }
    
    init() {
        self.endTime = LocalTime()
        self.startTime = LocalTime()
    }
}
