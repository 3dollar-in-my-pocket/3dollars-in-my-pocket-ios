import Foundation
struct LocalTime: Decodable {
    let hour: Int?
    let minute: Int?
    let nano: Int?
    let second: Int?
    
    enum CodingKeys: String, CodingKey {
        case hour
        case minute
        case nano
        case second
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.hour = try values.decodeIfPresent(Int.self, forKey: .hour)
        self.minute = try values.decodeIfPresent(Int.self, forKey: .minute)
        self.nano = try values.decodeIfPresent(Int.self, forKey: .nano)
        self.second = try values.decodeIfPresent(Int.self, forKey: .second)
    }
    
    init() {
        self.hour = nil
        self.minute = nil
        self.nano = nil
        self.second = nil
    }
    
    func toDate() -> Date {
        let calendar = Calendar.current
        
        var components = calendar.dateComponents(
            [.hour, .minute, .second, .nanosecond],
            from: Date()
        )
        components.hour = hour
        components.minute = minute
        components.second = second
        components.nanosecond = nano
        
        return calendar.date(from: components) ?? Date()
    }
}
