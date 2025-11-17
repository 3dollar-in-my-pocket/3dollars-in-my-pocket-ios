//
//  VersionUtils.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/07/19.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import Foundation

struct VersionUtils {
  
  static var appVersion: String {
    return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
  }
  
  static func isNeedUpdate(currentVersion: String, minimumVersion: String) -> Bool {
    let currentVersionArray = currentVersion.split(separator: ".").compactMap { Int($0) }
    let minimumVersionArray = minimumVersion.split(separator: ".").compactMap { Int($0) }

    // 버전 형식이 잘못된 경우 업데이트가 필요하지 않다고 가정
    guard currentVersionArray.count == 3 && minimumVersionArray.count == 3 else {
      return false
    }

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
