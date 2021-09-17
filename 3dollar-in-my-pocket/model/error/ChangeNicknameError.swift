//
//  ChangeNicknameError.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/09/17.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import Foundation

enum ChangeNicknameError: Int, LocalizedError {
  case alreadyExistedNickname = 409
  case badRequest = 400
  
  var errorDescription: String? {
    switch self {
    case .alreadyExistedNickname:
      return ""
    case .badRequest:
      return ""
    }
  }
}
