public enum DeleteReason: String {
  case NOSTORE = "NOSTORE"
  case WRONGNOPOSITION = "WRONGNOPOSITION"
  case OVERLAPSTORE = "OVERLAPSTORE"
  
  func getValue() -> String {
    return self.rawValue
  }
}
