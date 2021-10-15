//
//  RemoteConfigService.swift
//  3dollar-in-my-pocketTests
//
//  Created by Hyun Sik Yoo on 2021/07/20.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import RxSwift

@testable import dollar_in_my_pocket

struct RemoteConfigServiceMock: RemoteConfigProtocol {
  var fetchMinimalVersionObservable: Observable<String>?
  
  func fetchMinimalVersion() -> Observable<String> {
    return self.fetchMinimalVersionObservable ?? .empty()
  }
}
