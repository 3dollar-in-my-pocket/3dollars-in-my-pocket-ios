//
//  VersionUtilsTests.swift
//  3dollar-in-my-pocketTests
//
//  Created by Hyun Sik Yoo on 2021/07/20.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import XCTest

@testable import dollar_in_my_pocket

class VersionUtilsTests: XCTestCase {
  
  func testNeedUpdate1() throws {
    let currentVersion = "1.0.0"
    let minimumVersion = "0.0.0"
    let isNeedUpdate = VersionUtils.isNeedUpdate(
      currentVersion: currentVersion,
      minimumVersion: minimumVersion
    )
    
    XCTAssertEqual(isNeedUpdate, false)
  }
  
  func testNeedUpdate2() throws {
    let currentVersion = "1.0.0"
    let minimumVersion = "0.0.1"
    let isNeedUpdate = VersionUtils.isNeedUpdate(
      currentVersion: currentVersion,
      minimumVersion: minimumVersion
    )
    
    XCTAssertEqual(isNeedUpdate, false)
  }
  
  func testNeedUpdate3() throws {
    let currentVersion = "1.0.0"
    let minimumVersion = "0.1.0"
    let isNeedUpdate = VersionUtils.isNeedUpdate(
      currentVersion: currentVersion,
      minimumVersion: minimumVersion
    )
    
    XCTAssertEqual(isNeedUpdate, false)
  }
  
  func testNeedUpdate5() throws {
    let currentVersion = "1.0.0"
    let minimumVersion = "1.0.0"
    let isNeedUpdate = VersionUtils.isNeedUpdate(
      currentVersion: currentVersion,
      minimumVersion: minimumVersion
    )
    
    XCTAssertEqual(isNeedUpdate, false)
  }
  
  func testNeedUpdate6() throws {
    let currentVersion = "1.0.0"
    let minimumVersion = "2.0.0"
    let isNeedUpdate = VersionUtils.isNeedUpdate(
      currentVersion: currentVersion,
      minimumVersion: minimumVersion
    )
    
    XCTAssertEqual(isNeedUpdate, true)
  }
  
  func testNeedUpdate7() throws {
    let currentVersion = "1.0.0"
    let minimumVersion = "1.2.0"
    let isNeedUpdate = VersionUtils.isNeedUpdate(
      currentVersion: currentVersion,
      minimumVersion: minimumVersion
    )
    
    XCTAssertEqual(isNeedUpdate, true)
  }
  
  func testNeedUpdate8() throws {
    let currentVersion = "1.0.0"
    let minimumVersion = "1.0.3"
    let isNeedUpdate = VersionUtils.isNeedUpdate(
      currentVersion: currentVersion,
      minimumVersion: minimumVersion
    )
    
    XCTAssertEqual(isNeedUpdate, true)
  }
}
