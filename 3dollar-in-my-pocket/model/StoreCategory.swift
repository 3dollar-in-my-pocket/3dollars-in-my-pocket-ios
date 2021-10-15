import UIKit

public enum StoreCategory: String, Codable {
  case BUNGEOPPANG = "BUNGEOPPANG"
  case TAKOYAKI = "TAKOYAKI"
  case GYERANPPANG = "GYERANPPANG"
  case HOTTEOK = "HOTTEOK"
  case EOMUK = "EOMUK"
  case GUNGOGUMA = "GUNGOGUMA"
  case TTEOKBOKKI = "TTEOKBOKKI"
  case TTANGKONGPPANG = "TTANGKONGPPANG"
  case GUNOKSUSU = "GUNOKSUSU"
  case KKOCHI = "KKOCHI"
  case TOAST = "TOAST"
  case WAFFLE = "WAFFLE"
  case GUKWAPPANG = "GUKWAPPANG"
  case SUNDAE = "SUNDAE"
  case DALGONA = "DALGONA"
  
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
  }
  
  var lowcase: String {
    get {
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
  }
  
  func getValue() -> String {
    return self.rawValue
  }
}
