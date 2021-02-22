public enum StoreCategory: String, Codable {
  case BUNGEOPPANG = "BUNGEOPPANG"
  case TAKOYAKI = "TAKOYAKI"
  case GYERANPPANG = "GYERANPPANG"
  case HOTTEOK = "HOTTEOK"
  case EOMUK = "EOMUK"
  case GUNGOGUMA = "GUNGOGUMA"
  case TTEOKBOKI = "TTEOKBOKI"
  case TTANGKONGPPANG = "TTANGKONGPPANG"
  case GUNOKSUSU = "GUNOKSUSU"
  case KKOCHI = "KKOCHI"
  case TOAST = "TOAST"
  case WAFFLE = "WAFFLE"
  case GUKHWAPPANG = "GUKHWAPPANG"
  case SUNDAE = "SUNDAE"
  
  func getValue() -> String {
    return self.rawValue
  }
  
  static func index(_ index: Int) -> StoreCategory {
    switch index {
    case 0:
      return .BUNGEOPPANG
    case 1:
      return .TAKOYAKI
    case 2:
      return .GYERANPPANG
    case 3:
      return .HOTTEOK
    default:
      return .BUNGEOPPANG
    }
  }
  
  static func categoryToIndex(_ category: StoreCategory) -> Int {
    switch category {
    case .BUNGEOPPANG:
      return 0
    case .TAKOYAKI:
      return 1
    case .GYERANPPANG:
      return 2
    case .HOTTEOK:
      return 3
    default:
      return 0
    }
  }
}
