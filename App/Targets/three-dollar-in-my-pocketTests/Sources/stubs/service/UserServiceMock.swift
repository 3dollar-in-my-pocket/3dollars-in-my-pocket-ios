//
//  UserServiceMock.swift
//  3dollar-in-my-pocketTests
//
//  Created by Hyun Sik Yoo on 2021/07/11.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import RxSwift

@testable import dollar_in_my_pocket

struct UserServiceMock: UserServiceProtocol {
    var editNicknameObservable: Observable<Void>?
    var signinObservable: Observable<SigninResponse>?
    var signupObservable: Observable<SigninResponse>?
    var fetchUserInfoObservable: Observable<UserInfoResponse>?
    var withdrawalObservable: Observable<Void>?
    
    func signin(request: SigninRequest) -> Observable<SigninResponse> {
        return self.signinObservable ?? .empty()
    }
    
    func signup(request: SignupRequest) -> Observable<SigninResponse> {
        return self.signupObservable ?? .empty()
    }
    
    func withdrawal(userId: Int) -> Observable<Void> {
        return .empty()
    }
    
    func changeNickname(name: String) -> Observable<User> {
        return .empty()
    }
    
    func fetchUserInfo() -> Observable<UserInfoResponse> {
        return self.fetchUserInfoObservable ?? .empty()
    }
    
    func withdrawal() -> Observable<Void> {
        return self.withdrawalObservable
        ?? .error(CommonError(desc: "withdrawalObservable 가 정의되지 않았습니다."))
    }
    
    func fetchUserActivity() -> Observable<UserWithActivityResponse> {
        return .empty()
    }
    
    func signinAnonymous() -> Observable<SigninResponse> {
        return .empty()
    }
    
    func connectAccount(request: SigninRequest) -> Observable<String> {
        return .empty()
    }
    
    func signout() -> Observable<Void> {
        return .empty()
    }
    
    func editNickname(name: String) -> Observable<Void> {
        return self.editNicknameObservable
        ?? .error(BaseError.custom("editNicknameObservable가 정의되지 않았습니다."))
    }
    
    func fetchUser() -> Observable<User> {
        return .empty()
    }
    
    func fetchUserActivity() -> Observable<User> {
        return .empty()
    }
    
    func changeMarketingConsent(marketingConsentType: MarketingConsentType) -> Observable<String> {
        return .empty()
    }
}
