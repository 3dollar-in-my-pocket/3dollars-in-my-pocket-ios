//
//  VisitHistoryWithUserResponse.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/11/12.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import Foundation

struct VisitHistoryWithUserResponse: Decodable {
  
  let createdAt: String
  let storeId: Int
  let type: VisitType
  let updatedAt: String
  let user: UserInfoResponse
  let visitHistoryId: Int
  
  enum CodingKeys: String, CodingKey {
    case createdAt
    case storeId
    case type
    case updatedAt
    case user
    case visitHistoryId
  }
  
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    self.createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
    self.storeId = try values.decodeIfPresent(Int.self, forKey: .storeId) ?? 0
    self.type = try values.decodeIfPresent(VisitType.self, forKey: .type) ?? .exists
    self.updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt) ?? ""
    self.user = try values.decodeIfPresent(
      UserInfoResponse.self,
      forKey: .user
    ) ?? UserInfoResponse()
    self.visitHistoryId = try values.decodeIfPresent(Int.self, forKey: .visitHistoryId) ?? 0
  }
}
