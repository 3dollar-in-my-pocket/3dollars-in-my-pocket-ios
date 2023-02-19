//
//  SigninManagerMock.swift
//  3dollar-in-my-pocketTests
//
//  Created by Hyun Sik Yoo on 2021/08/15.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import RxSwift

@testable import dollar_in_my_pocket

struct SigninManagerMock: SigninManagerProtocol {
    func signout() -> RxSwift.Observable<Void> {
        return .empty()
    }
    
    func logout() -> RxSwift.Observable<Void> {
        return .empty()
    }
    
    var signinObservable: Observable<SigninRequest>?
    
    func signin() -> Observable<SigninRequest> {
        return self.signinObservable ?? .empty()
    }
}
