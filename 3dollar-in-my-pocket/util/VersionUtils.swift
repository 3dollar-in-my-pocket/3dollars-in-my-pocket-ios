//
//  VersionUtils.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/07/19.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import Foundation

struct VersionUtils {
  
  static var appVersion: String? {
    return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
  }
  
  static func isNeedUpdate(minimumVersion: String) -> Bool {
    guard let appVersion = self.appVersion else { return true }
    let currentVersionArray = appVersion.split(separator: ".")
    let minimumVersionArray = minimumVersion.split(separator: ".")
    
    if currentVersionArray[0] > minimumVersionArray[0] {
      return false
    } else if currentVersionArray[0] == minimumVersionArray[0] {
      if currentVersionArray[1] > minimumVersionArray[1] {
        return false
      } else if currentVersionArray[1] == minimumVersionArray[1] {
        if currentVersionArray[2] >= minimumVersionArray[2] {
          return false
        } else {
          return true
        }
      } else {
        return true
      }
    } else {
      return true
    }
  }
}
