//
//  NicknameViewModelTests.swift
//  3dollar-in-my-pocketTests
//
//  Created by Hyun Sik Yoo on 2021/08/16.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

@testable import dollar_in_my_pocket

class NicknameViewModelTests: XCTestCase {
  var disposeBag: DisposeBag!
  var userDefaults: UserDefaultsUtil!
  var userService: UserServiceMock!
  var schedular: TestScheduler!
  
  override func setUp() {
    super.setUp()
    
    self.disposeBag = DisposeBag()
    self.userDefaults = UserDefaultsUtil(name: #file)
    self.userService = UserServiceMock()
    self.schedular = TestScheduler(initialClock: 0)
  }
  
  override func tearDown() {
    super.tearDown()
    
    self.disposeBag = nil
    self.userDefaults = nil
    self.userService = nil
    self.schedular = nil
  }
  
  func testStartButtonEnable() {
    // Setup
    let startButtonEnableObservable = self.schedular.createObserver(Bool.self)
    let viewModel = NicknameViewModel(
      signinRequest: .init(socialType: .KAKAO, token: "token"),
      userDefaults: self.userDefaults,
      userService: self.userService
    )
    
    // Bind input
    self.schedular.createColdObservable([.next(210, "123")])
      .bind(to: viewModel.input.nickname)
      .disposed(by: self.disposeBag)
    
    viewModel.output.startButtonEnable
      .bind(to: startButtonEnableObservable)
      .disposed(by: self.disposeBag)
    
    self.schedular.start()
    XCTAssertRecordedElements(startButtonEnableObservable.events, [true])
  }
  
  func testStartButtonDisable() {
    // Setup
    let startButtonEnableObservable = self.schedular.createObserver(Bool.self)
    let viewModel = NicknameViewModel(
      signinRequest: .init(socialType: .KAKAO, token: "token"),
      userDefaults: self.userDefaults,
      userService: self.userService
    )
    
    // Bind input
    self.schedular.createColdObservable([
      .next(210, "123"),
      .next(220, "")
    ])
      .bind(to: viewModel.input.nickname)
      .disposed(by: self.disposeBag)
    
    viewModel.output.startButtonEnable
      .bind(to: startButtonEnableObservable)
      .disposed(by: self.disposeBag)
    
    self.schedular.start()
    XCTAssertRecordedElements(startButtonEnableObservable.events, [true, false])
  }
  
  func testBlankNickname() {
    // Setup
    let startButtonEnableObservable = self.schedular.createObserver(Bool.self)
    let viewModel = NicknameViewModel(
      signinRequest: .init(socialType: .KAKAO, token: "token"),
      userDefaults: self.userDefaults,
      userService: self.userService
    )
    
    // Bind input
    self.schedular.createColdObservable([.next(210, "   ")])
      .bind(to: viewModel.input.nickname)
      .disposed(by: self.disposeBag)
    
    viewModel.output.startButtonEnable
      .bind(to: startButtonEnableObservable)
      .disposed(by: self.disposeBag)
    
    self.schedular.start()
    XCTAssertRecordedElements(startButtonEnableObservable.events, [false])
  }
  
  func testAlreadyExistedNickname() {
    let startButtonEnableObservable = self.schedular.createObserver(Bool.self)
    let errorLabelHiddenObservable = self.schedular.createObserver(Bool.self)
    
    self.userService.signupObservable = .create { observer in
      observer.onError(HTTPError.badRequest)
      return Disposables.create()
    }
    let viewModel = NicknameViewModel(
      signinRequest: .init(socialType: .KAKAO, token: "token"),
      userDefaults: self.userDefaults,
      userService: self.userService
    )
    
    self.schedular.createColdObservable([.next(210, "nickname")])
      .bind(to: viewModel.input.nickname)
      .disposed(by: self.disposeBag)
    self.schedular.createColdObservable([.next(220, ())])
      .bind(to: viewModel.input.tapStartButton)
      .disposed(by: self.disposeBag)
    
    viewModel.output.startButtonEnable
      .bind(to: startButtonEnableObservable)
      .disposed(by: self.disposeBag)
    viewModel.output.errorLabelHidden
      .bind(to: errorLabelHiddenObservable)
      .disposed(by: self.disposeBag)
    
    self.schedular.start()
    XCTAssertRecordedElements(startButtonEnableObservable.events, [true])
    XCTAssertRecordedElements(errorLabelHiddenObservable.events, [false])
  }
  
  func testFailSignup() {
    let startButtonEnableObservable = self.schedular.createObserver(Bool.self)
    let showErrorAlertObservable = self.schedular.createObserver(Error.self)
    
    self.userService.signupObservable = .create { observer in
      observer.onError(BaseError.custom("Error in signup"))
      return Disposables.create()
    }
    let viewModel = NicknameViewModel(
      signinRequest: .init(socialType: .KAKAO, token: "token"),
      userDefaults: self.userDefaults,
      userService: self.userService
    )
    
    self.schedular.createColdObservable([.next(210, "nickname")])
      .bind(to: viewModel.input.nickname)
      .disposed(by: self.disposeBag)
    self.schedular.createColdObservable([.next(220, ())])
      .bind(to: viewModel.input.tapStartButton)
      .disposed(by: self.disposeBag)
    
    viewModel.output.startButtonEnable
      .bind(to: startButtonEnableObservable)
      .disposed(by: self.disposeBag)
    viewModel.showErrorAlert
      .bind(to: showErrorAlertObservable)
      .disposed(by: self.disposeBag)
    
    self.schedular.start()
    XCTAssertRecordedElements(startButtonEnableObservable.events, [true])
    XCTAssertEqual(showErrorAlertObservable.events.count, 1)
  }
  
  func testSuccessSignup() {
    let startButtonEnableObservable = self.schedular.createObserver(Bool.self)
    let goToMainObservable = self.schedular.createObserver(Void.self)
    let showLoadingObservable = self.schedular.createObserver(Bool.self)
    let signinResponse = SigninResponse()
    
    self.userService.signupObservable = .create { observer in
      observer.onNext(signinResponse)
      return Disposables.create()
    }
    let viewModel = NicknameViewModel(
      signinRequest: .init(socialType: .KAKAO, token: "token"),
      userDefaults: self.userDefaults,
      userService: self.userService
    )
    
    self.schedular.createColdObservable([.next(210, "nickname")])
      .bind(to: viewModel.input.nickname)
      .disposed(by: self.disposeBag)
    self.schedular.createColdObservable([.next(220, ())])
      .bind(to: viewModel.input.tapStartButton)
      .disposed(by: self.disposeBag)
    
    viewModel.output.startButtonEnable
      .bind(to: startButtonEnableObservable)
      .disposed(by: self.disposeBag)
    viewModel.output.goToMain
      .bind(to: goToMainObservable)
      .disposed(by: self.disposeBag)
    viewModel.showLoading
      .bind(to: showLoadingObservable)
      .disposed(by: self.disposeBag)
    
    self.schedular.start()
    XCTAssertRecordedElements(startButtonEnableObservable.events, [true])
    XCTAssertRecordedElements(showLoadingObservable.events, [true, false])
    XCTAssertEqual(goToMainObservable.events.count, 1)
  }
}
