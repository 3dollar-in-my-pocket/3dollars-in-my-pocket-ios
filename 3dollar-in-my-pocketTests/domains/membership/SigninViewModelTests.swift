import XCTest
import RxSwift
import RxTest

@testable import dollar_in_my_pocket

class SigninViewModelTests: XCTestCase {
  var disposeBag: DisposeBag!
  var userDefaults: UserDefaultsUtil!
  var signinManager: SigninManagerMock!
  var userService: UserServiceMock!
  var schedular: TestScheduler!
  
  override func setUp() {
    super.setUp()
    
    self.disposeBag = DisposeBag()
    self.userDefaults = UserDefaultsUtil(name: #file)
    self.signinManager = SigninManagerMock()
    self.userService = UserServiceMock()
    self.schedular = TestScheduler(initialClock: 0)
  }
  
  override func tearDown() {
    super.tearDown()
    
    self.disposeBag = nil
    self.userDefaults = nil
    self.signinManager = nil
    self.schedular = nil
  }
  
  func testTapKakaoWithSignin() {
    // Setup
    let goToMainExpectation = self.schedular.createObserver(Void.self)
    
    self.signinManager.signinObservable = .create { observer in
      observer.onNext(SigninRequest(socialType: .KAKAO, token: "token"))
      return Disposables.create()
    }
    self.userService.signinObservable = .create { observer in
      observer.onNext(SigninResponse())
      return Disposables.create()
    }
    
    let viewModel = SignInViewModel(
      userDefaults: self.userDefaults,
      userService: self.userService,
      kakaoManager: self.signinManager,
      appleManager: self.signinManager
    )
    
    // Bind input
    self.schedular.createColdObservable([.next(210, ())])
      .bind(to: viewModel.input.tapKakaoButton)
      .disposed(by: self.disposeBag)
    
    // Bind output
    viewModel.output.goToMain
      .bind(to: goToMainExpectation)
      .disposed(by: self.disposeBag)
    
    self.schedular.start()
    XCTAssertEqual(goToMainExpectation.events.count, 1)
  }
  
  func testTapKakaoWithSignup() {
    // Setup
    let goToNicknameExpectation = self.schedular.createObserver(SigninRequest.self)
    let signinRequest = SigninRequest(socialType: .KAKAO, token: "token")
    
    self.signinManager.signinObservable = .create { observer in
      observer.onNext(signinRequest)
      return Disposables.create()
    }
    self.userService.signinObservable = .create { observer in
      observer.onError(HTTPError.notFound)
      return Disposables.create()
    }
    
    let viewModel = SignInViewModel(
      userDefaults: self.userDefaults,
      userService: self.userService,
      kakaoManager: self.signinManager,
      appleManager: self.signinManager
    )
    
    // Bind input
    self.schedular.createColdObservable([.next(210, ())])
      .bind(to: viewModel.input.tapKakaoButton)
      .disposed(by: self.disposeBag)
    
    // Bind output
    viewModel.output.goToNickname
      .bind(to: goToNicknameExpectation)
      .disposed(by: self.disposeBag)
    
    self.schedular.start()
    XCTAssertRecordedElements(goToNicknameExpectation.events, [signinRequest])
  }
  
  func testTapKakaoWithKakaoFail() {
    // Setup
    let showErrorAlertExpectation = self.schedular.createObserver(Error.self)
    let kakaoError = BaseError.custom("error in kakao")
    
    self.signinManager.signinObservable = .create { observer in
      observer.onError(kakaoError)
      return Disposables.create()
    }
    
    let viewModel = SignInViewModel(
      userDefaults: self.userDefaults,
      userService: self.userService,
      kakaoManager: self.signinManager,
      appleManager: self.signinManager
    )
    
    // Bind input
    self.schedular.createColdObservable([.next(210, ())])
      .bind(to: viewModel.input.tapKakaoButton)
      .disposed(by: self.disposeBag)
    
    // Bind output
    viewModel.showErrorAlert
      .bind(to: showErrorAlertExpectation)
      .disposed(by: self.disposeBag)
    
    self.schedular.start()
    XCTAssertEqual(showErrorAlertExpectation.events.count, 1)
  }
  
  func testTapKakaoWithSigninFail() {
    // Setup
    let showErrorAlertExpectation = self.schedular.createObserver(Error.self)
    let signinRequest = SigninRequest(socialType: .KAKAO, token: "token")
    let signinError = BaseError.custom("error in signin")
    
    self.signinManager.signinObservable = .create { observer in
      observer.onNext(signinRequest)
      return Disposables.create()
    }
    self.userService.signinObservable = .create { observer in
      observer.onError(signinError)
      return Disposables.create()
    }
    
    let viewModel = SignInViewModel(
      userDefaults: self.userDefaults,
      userService: self.userService,
      kakaoManager: self.signinManager,
      appleManager: self.signinManager
    )
    
    // Bind input
    self.schedular.createColdObservable([.next(210, ())])
      .bind(to: viewModel.input.tapKakaoButton)
      .disposed(by: self.disposeBag)
    
    // Bind output
    viewModel.showErrorAlert
      .bind(to: showErrorAlertExpectation)
      .disposed(by: self.disposeBag)
    
    self.schedular.start()
    XCTAssertEqual(showErrorAlertExpectation.events.count, 1)
  }
  
  func testTapAppleWithSignin() {
    // Setup
    let goToMainExpectation = self.schedular.createObserver(Void.self)
    
    self.signinManager.signinObservable = .create { observer in
      observer.onNext(SigninRequest(socialType: .APPLE, token: "token"))
      return Disposables.create()
    }
    self.userService.signinObservable = .create { observer in
      observer.onNext(SigninResponse())
      return Disposables.create()
    }
    
    let viewModel = SignInViewModel(
      userDefaults: self.userDefaults,
      userService: self.userService,
      kakaoManager: self.signinManager,
      appleManager: self.signinManager
    )
    
    // Bind input
    self.schedular.createColdObservable([.next(210, ())])
      .bind(to: viewModel.input.tapAppleButton)
      .disposed(by: self.disposeBag)
    
    // Bind output
    viewModel.output.goToMain
      .bind(to: goToMainExpectation)
      .disposed(by: self.disposeBag)
    
    self.schedular.start()
    XCTAssertEqual(goToMainExpectation.events.count, 1)
  }
  
  func testTapAppleWithSignup() {
    // Setup
    let goToNicknameExpectation = self.schedular.createObserver(SigninRequest.self)
    let signinRequest = SigninRequest(socialType: .APPLE, token: "token")
    
    self.signinManager.signinObservable = .create { observer in
      observer.onNext(signinRequest)
      return Disposables.create()
    }
    self.userService.signinObservable = .create { observer in
      observer.onError(HTTPError.notFound)
      return Disposables.create()
    }
    
    let viewModel = SignInViewModel(
      userDefaults: self.userDefaults,
      userService: self.userService,
      kakaoManager: self.signinManager,
      appleManager: self.signinManager
    )
    
    // Bind input
    self.schedular.createColdObservable([.next(210, ())])
      .bind(to: viewModel.input.tapAppleButton)
      .disposed(by: self.disposeBag)
    
    // Bind output
    viewModel.output.goToNickname
      .bind(to: goToNicknameExpectation)
      .disposed(by: self.disposeBag)
    
    self.schedular.start()
    XCTAssertRecordedElements(goToNicknameExpectation.events, [signinRequest])
  }
  
  func testTapAppleWithAppleFail() {
    // Setup
    let showErrorAlertExpectation = self.schedular.createObserver(Error.self)
    let appleError = BaseError.custom("error in apple")
    
    self.signinManager.signinObservable = .create { observer in
      observer.onError(appleError)
      return Disposables.create()
    }
    
    let viewModel = SignInViewModel(
      userDefaults: self.userDefaults,
      userService: self.userService,
      kakaoManager: self.signinManager,
      appleManager: self.signinManager
    )
    
    // Bind input
    self.schedular.createColdObservable([.next(210, ())])
      .bind(to: viewModel.input.tapAppleButton)
      .disposed(by: self.disposeBag)
    
    // Bind output
    viewModel.showErrorAlert
      .bind(to: showErrorAlertExpectation)
      .disposed(by: self.disposeBag)
    
    self.schedular.start()
    XCTAssertEqual(showErrorAlertExpectation.events.count, 1)
  }
  
  func testTapAppleWithSigninFail() {
    // Setup
    let showErrorAlertExpectation = self.schedular.createObserver(Error.self)
    let signinRequest = SigninRequest(socialType: .APPLE, token: "token")
    let signinError = BaseError.custom("error in signin")
    
    self.signinManager.signinObservable = .create { observer in
      observer.onNext(signinRequest)
      return Disposables.create()
    }
    self.userService.signinObservable = .create { observer in
      observer.onError(signinError)
      return Disposables.create()
    }
    
    let viewModel = SignInViewModel(
      userDefaults: self.userDefaults,
      userService: self.userService,
      kakaoManager: self.signinManager,
      appleManager: self.signinManager
    )
    
    // Bind input
    self.schedular.createColdObservable([.next(210, ())])
      .bind(to: viewModel.input.tapAppleButton)
      .disposed(by: self.disposeBag)
    
    // Bind output
    viewModel.showErrorAlert
      .bind(to: showErrorAlertExpectation)
      .disposed(by: self.disposeBag)
    
    self.schedular.start()
    XCTAssertEqual(showErrorAlertExpectation.events.count, 1)
  }
}
