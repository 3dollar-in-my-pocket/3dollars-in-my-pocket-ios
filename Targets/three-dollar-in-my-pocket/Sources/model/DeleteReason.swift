public enum DeleteReason: String {
  case NOSTORE = "NOSTORE"
  case WRONGCONTENT = "WRONG_CONTENT"
  case OVERLAPSTORE = "OVERLAPSTORE"
  
  func getValue() -> String {
    return self.rawValue
  }
}
