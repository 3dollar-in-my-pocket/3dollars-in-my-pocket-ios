//
//  MedalResponse.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/12/09.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import Foundation

struct MedalResponse: Decodable {
    let iconUrl: String
    let medalId: Int
    let name: String
    
    enum CodingKeys: String, CodingKey {
      case iconUrl
      case medalId
      case name
    }
    
    init() {
        self.iconUrl = ""
        self.medalId = -1
        self.name = ""
    }
    
    init(from decoder: Decoder) throws {
      let values = try decoder.container(keyedBy: CodingKeys.self)
      
      self.iconUrl = try values.decodeIfPresent(String.self, forKey: .iconUrl) ?? ""
      self.medalId = try values.decodeIfPresent(Int.self, forKey: .medalId) ?? -1
      self.name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
    }
}
