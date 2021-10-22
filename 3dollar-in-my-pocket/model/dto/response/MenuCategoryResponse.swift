//
//  MenuCategoryResponse.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/10/22.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import Foundation

struct MenuCategoryResponse: Decodable {
  let category: String
  let description: String
  let isNew: Bool
  let name: String
  
  enum CodingKeys: String, CodingKey {
    case category
    case description
    case isNew
    case name
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    self.category = try values.decodeIfPresent(String.self, forKey: .category) ?? ""
    self.description = try values.decodeIfPresent(String.self, forKey: .description) ?? ""
    self.isNew = try values.decodeIfPresent(Bool.self, forKey: .isNew) ?? false
    self.name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
  }
}
