enum WeekDay: String {
  case monday = "monday"
  case tuesday = "tuesday"
  case wednesday = "wednesday"
  case thursday = "thursday"
  case friday = "friday"
  case saturday = "saturday"
  case sunday = "sunday"
  
  func getIntValue() -> Int {
    switch self {
    case .sunday: return 0
    case .monday: return 1
    case .tuesday: return 2
    case .wednesday: return 3
    case .thursday: return 4
    case .friday: return 5
    case .saturday: return 6
    }
  }
}
