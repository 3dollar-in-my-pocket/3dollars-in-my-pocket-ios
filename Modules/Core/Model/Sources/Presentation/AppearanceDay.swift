import Foundation

public enum AppearanceDay: String, Hashable, Codable, Comparable {
    case monday = "MONDAY"
    case tuesday = "TUESDAY"
    case wednesday = "WEDNESDAY"
    case thursday = "THURSDAY"
    case friday = "FRIDAY"
    case saturday = "SATURDAY"
    case sunday = "SUNDAY"
    case unknown
    
    init(value: String) {
        self = AppearanceDay(rawValue: value) ??  .unknown
    }
    
    public init(from decoder: Decoder) throws {
        self = try AppearanceDay(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
    
    private var sortOrder: Int {
        switch self {
        case .monday: return 0
        case .tuesday: return 1
        case .wednesday: return 2
        case .thursday: return 3
        case .friday: return 4
        case .saturday: return 5
        case .sunday: return 6
        case .unknown: return 999
        }
    }
    
    public static func < (lhs: AppearanceDay, rhs: AppearanceDay) -> Bool {
        return lhs.sortOrder < rhs.sortOrder
    }
}
