//
//  UserServiceMock.swift
//  3dollar-in-my-pocketTests
//
//  Created by Hyun Sik Yoo on 2021/07/11.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import RxSwift

@testable import 가슴속3천원_debug

struct UserServiceMock: UserServiceProtocol {
  var validateTokenObservable: Observable<Void>?
  var signinObservable: Observable<SigninResponse>?
  
  func validateToken(token: String) -> Observable<Void> {
    return self.validateTokenObservable ?? .empty()
  }
  
  func signin(request: SigninRequest) -> Observable<SigninResponse> {
    return self.signinObservable ?? .empty()
  }
  
  func signup(request: SignupRequest) -> Observable<SigninResponse> {
    return .empty()
  }
  
  func withdrawal(userId: Int) -> Observable<Void> {
    return .empty()
  }
  
  func changeNickname(name: String) -> Observable<User> {
    return .empty()
  }
  
  func fetchUserInfo() -> Observable<UserInfoResponse> {
    return .empty()
  }
}
