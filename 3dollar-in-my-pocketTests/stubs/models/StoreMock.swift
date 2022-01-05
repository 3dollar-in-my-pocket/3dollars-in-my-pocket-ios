//
//  StoresMock.swift
//  3dollar-in-my-pocketTests
//
//  Created by Hyun Sik Yoo on 2021/09/25.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import Foundation

@testable import dollar_in_my_pocket

struct StoreMock {
  func fetchHomeStores() -> [StoreWithVisitsAndDistanceResponse] {
    let stores: [StoreWithVisitsAndDistanceResponse] = DataUtils.load("HomeStores.json")
    
    return stores
  }
}
