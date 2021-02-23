import UIKit

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
  
  var name: String {
    get {
      switch self {
      case .BUNGEOPPANG:
        return "shared_category_bungeoppang".localized
      case .GYERANPPANG:
        return "shared_category_gyeranppang".localized
      case .TAKOYAKI:
        return "shared_category_takoyaki".localized
      case .HOTTEOK:
        return "shared_category_hotteok".localized
      case .EOMUK:
        return "shared_category_eomuk".localized
      case .GUKHWAPPANG:
        return "shared_category_gukhwappang".localized
      case .GUNGOGUMA:
        return "shared_category_gungoguma".localized
      case .GUNOKSUSU:
        return "shared_category_gunoksusu".localized
      case .KKOCHI:
        return "shared_category_kkochi".localized
      case .SUNDAE:
        return "shared_category_sundae".localized
      case .TOAST:
        return "shared_category_toast".localized
      case .TTANGKONGPPANG:
        return "shared_category_ttangkongppang".localized
      case .TTEOKBOKI:
        return "shared_category_tteokboki".localized
      case .WAFFLE:
        return "shared_category_waffle".localized
      }
    }
  }
  
  var image: UIImage? {
    get {
      switch self {
      case .BUNGEOPPANG:
        return UIImage(named: "img_60_bungeoppang")
      case .GYERANPPANG:
        return UIImage(named: "img_60_gyeranppang")
      case .TAKOYAKI:
        return UIImage(named: "img_60_takoyaki")
      case .HOTTEOK:
        return UIImage(named: "img_60_hotteok")
      case .EOMUK:
        return UIImage(named: "img_60_eomuk")
      case .GUKHWAPPANG:
        return UIImage(named: "img_60_gukhwappang")
      case .GUNGOGUMA:
        return UIImage(named: "img_60_gungoguma")
      case .GUNOKSUSU:
        return UIImage(named: "img_60_gunoksusu")
      case .KKOCHI:
        return UIImage(named: "img_60_kkochi")
      case .SUNDAE:
        return UIImage(named: "img_60_sundae")
      case .TOAST:
        return UIImage(named: "img_60_toast")
      case .TTANGKONGPPANG:
        return UIImage(named: "img_60_ttangkongppang")
      case .TTEOKBOKI:
        return UIImage(named: "img_60_tteokboki")
      case .WAFFLE:
        return UIImage(named: "img_60_waffle")
      }
    }
  }
  
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
