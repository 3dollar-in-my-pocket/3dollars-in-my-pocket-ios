import UIKit

public enum StreetFoodStoreCategory: String, Codable {
  case BUNGEOPPANG
  case TAKOYAKI
  case GYERANPPANG
  case HOTTEOK
  case EOMUK
  case GUNGOGUMA
  case TTEOKBOKKI
  case TTANGKONGPPANG
  case GUNOKSUSU
  case KKOCHI
  case TOAST
  case WAFFLE
  case GUKWAPPANG
  case SUNDAE
  case DALGONA
  
  var name: String {
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
      case .GUKWAPPANG:
        return "shared_category_gukwappang".localized
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
      case .TTEOKBOKKI:
        return "shared_category_tteokbokki".localized
      case .WAFFLE:
        return "shared_category_waffle".localized
      case .DALGONA:
        return "shared_category_dalgona".localized
      }
  }
  
  var image: UIImage? {
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
      case .GUKWAPPANG:
        return UIImage(named: "img_60_gukwappang")
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
      case .TTEOKBOKKI:
        return UIImage(named: "img_60_tteokbokki")
      case .WAFFLE:
        return UIImage(named: "img_60_waffle")
      case .DALGONA:
        return UIImage(named: "img_60_dalgona")
      }
  }
  
  var lowcase: String {
      switch self {
      case .BUNGEOPPANG:
        return "bungeoppang"
      case .GYERANPPANG:
        return "gyeranppang"
      case .TAKOYAKI:
        return "takoyaki"
      case .HOTTEOK:
        return "hotteok"
      case .EOMUK:
        return "eomuk"
      case .GUKWAPPANG:
        return "gukwappang"
      case .GUNGOGUMA:
        return "gungoguma"
      case .GUNOKSUSU:
        return "gunoksusu"
      case .KKOCHI:
        return "kkochi"
      case .SUNDAE:
        return "sundae"
      case .TOAST:
        return "toast"
      case .TTANGKONGPPANG:
        return "ttangkongppang"
      case .TTEOKBOKKI:
        return "tteokbokki"
      case .WAFFLE:
        return "waffle"
      case .DALGONA:
        return "dalgona"
      }
  }
  
  func getValue() -> String {
    return self.rawValue
  }
}
