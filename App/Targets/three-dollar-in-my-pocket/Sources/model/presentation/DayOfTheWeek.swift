enum DayOfTheWeek: String {
    case monday = "MONDAY"
    case tuesday = "TUESDAY"
    case wednesday = "WEDNESDAY"
    case thursday = "THURSDAY"
    case friday = "FRIDAY"
    case saturday = "SATURDAY"
    case sunday = "SUNDAY"
    
    init(value: String) {
        self = DayOfTheWeek(rawValue: value) ?? .monday
    }
    
    var fullText: String {
        switch self {
        case .monday:
            return "monday_full".localized
            
        case .tuesday:
            return "tuesday_full".localized
            
        case .wednesday:
            return "wednesday_full".localized
            
        case .thursday:
            return "thursday_full".localized
            
        case .friday:
            return "friday_full".localized
            
        case .saturday:
            return "saturday_full".localized
            
        case .sunday:
            return "sunday_full".localized
        }
    }
    
    var shortText: String {
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