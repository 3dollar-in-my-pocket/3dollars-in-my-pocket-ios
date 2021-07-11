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
  
  func validateToken(token: String) -> Observable<Void> {
    return self.validateTokenObservable ?? .empty()
  }
  
  func signIn(user: User) -> Observable<SignIn> {
    return .empty()
  }
  
  func setNickname(nickname: String, id: Int, token: String) -> Observable<Void> {
    return .empty()
  }
  
  func getUserInfo(userId: Int) -> Observable<User> {
    return .empty()
  }
  
  func withdrawal(userId: Int) -> Observable<Void> {
    return .empty()
  }
  
  func changeNickname(nickname: String) -> Observable<String> {
    return .empty()
  }
  
  func getUserInfo() -> Observable<User> {
    return .empty()
  }
}
