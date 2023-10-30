public enum DayOfTheWeek: String, Decodable {
    case monday = "MONDAY"
    case tuesday = "TUESDAY"
    case wednesday = "WEDNESDAY"
    case thursday = "THURSDAY"
    case friday = "FRIDAY"
    case saturday = "SATURDAY"
    case sunday = "SUNDAY"

    public init(value: String) {
        self = DayOfTheWeek(rawValue: value) ?? .monday
    }

    public var fullText: String {
        switch self {
        case .monday:
            return "월요일"

        case .tuesday:
            return "화요일"

        case .wednesday:
            return "수요일"

        case .thursday:
            return "목요일"

        case .friday:
            return "금요일"

        case .saturday:
            return "토요일"

        case .sunday:
            return "일요일"
        }
    }

    public var shortText: String {
        switch self {
        case .monday:
            return "월"

        case .tuesday:
            return "화"

        case .wednesday:
            return "수"

        case .thursday:
            return "목"

        case .friday:
            return "금"

        case .saturday:
            return "토"

        case .sunday:
            return "일"
        }
    }
}
