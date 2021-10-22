//
//  MenuCategoryResponse.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/10/22.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import UIKit

struct MenuCategoryResponse: Decodable {
  let category: StoreCategory
  let description: String
  let isNew: Bool
  let name: String
  
  var image: UIImage? {
    get {
      switch self.category {
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
  
  enum CodingKeys: String, CodingKey {
    case category
    case description
    case isNew
    case name
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    self.category = try values.decodeIfPresent(StoreCategory.self, forKey: .category) ?? .BUNGEOPPANG
    self.description = try values.decodeIfPresent(String.self, forKey: .description) ?? ""
    self.isNew = try values.decodeIfPresent(Bool.self, forKey: .isNew) ?? false
    self.name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
  }
}
