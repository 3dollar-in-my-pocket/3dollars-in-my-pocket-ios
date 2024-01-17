import Foundation

public enum AppearanceDay: String, Hashable {
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
}
