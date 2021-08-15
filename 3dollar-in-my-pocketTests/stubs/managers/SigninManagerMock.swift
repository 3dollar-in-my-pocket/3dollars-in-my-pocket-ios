//
//  SigninManagerMock.swift
//  3dollar-in-my-pocketTests
//
//  Created by Hyun Sik Yoo on 2021/08/15.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import RxSwift

@testable import 가슴속3천원_debug

struct SigninManagerMock: SigninManagerProtocol {
  var signinObservable: Observable<SigninRequest>?
  
  func signin() -> Observable<SigninRequest> {
    return self.signinObservable ?? .empty()
  }
}
