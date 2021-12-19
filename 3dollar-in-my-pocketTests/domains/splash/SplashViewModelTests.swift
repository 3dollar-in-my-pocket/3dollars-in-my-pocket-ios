import XCTest
import RxSwift
import RxTest

@testable import dollar_in_my_pocket

class SplashViewModelTests: XCTestCase {
    var disposeBag: DisposeBag!
    var userServiceMock: UserServiceMock!
    var medalServiceMock: MedalServiceMock!
    var remoteConfigServiceMock: RemoteConfigServiceMock!
    var userDefaults: UserDefaultsUtil!
    var schedular: TestScheduler!
    
    override func setUp() {
        super.setUp()
        
        self.disposeBag = DisposeBag()
        self.userServiceMock = UserServiceMock()
        self.medalServiceMock = MedalServiceMock()
        self.remoteConfigServiceMock = RemoteConfigServiceMock()
        self.userDefaults = UserDefaultsUtil(name: #file)
        self.schedular = TestScheduler(initialClock: 0)
    }
    
    override func tearDown() {
        super.tearDown()
        
        self.disposeBag = nil
        self.userServiceMock = nil
        self.userDefaults = nil
        self.schedular = nil
    }
    
//    func testNeedUpdate() {
//        let showUpdateExpectation = self.schedular.createObserver(Void.self)
//        
//        self.remoteConfigServiceMock.fetchMinimalVersionObservable = .create { observer in
//            observer.onNext("4.0.0")
//            observer.onCompleted()
//            return Disposables.create()
//        }
//        
//        let viewModel = SplashViewModel(
//            userDefaults: self.userDefaults,
//            userService: self.userServiceMock,
//            remoteConfigService: self.remoteConfigServiceMock,
//            medalContext: MedalContext.shared,
//            medalService: self.medalServiceMock
//        )
//        
//        // Bind input
//        self.schedular.createColdObservable([.next(210, ())])
//            .bind(to: viewModel.input.viewDidLoad)
//            .disposed(by: self.disposeBag)
//        
//        // Bind output
//        viewModel.output.showUpdateAlert
//            .bind(to: showUpdateExpectation)
//            .disposed(by: self.disposeBag)
//        
//        self.schedular.start()
//        
//        // Assert
//        XCTAssertEqual(showUpdateExpectation.events.count, 1)
//    }
//    
//    func testValidateTokenSuccess() {
//        // Setup
//        let goToMainExpectation = self.schedular.createObserver(Void.self)
//        
//        self.remoteConfigServiceMock.fetchMinimalVersionObservable = .create { observer in
//            observer.onNext("1.0.0")
//            observer.onCompleted()
//            return Disposables.create()
//        }
//        self.userServiceMock.fetchUserInfoObservable = .create { observer in
//            observer.onNext(UserInfoResponse())
//            observer.onCompleted()
//            return Disposables.create()
//        }
//        self.userDefaults.setUserToken(token: "test token")
//        
//        let viewModel = SplashViewModel(
//            userDefaults: self.userDefaults,
//            userService: self.userServiceMock,
//            remoteConfigService: self.remoteConfigServiceMock,
//            medalContext: MedalContext.shared,
//            medalService: self.medalServiceMock
//        )
//        
//        // Bind input
//        self.schedular.createColdObservable([.next(210, ())])
//            .bind(to: viewModel.input.viewDidLoad)
//            .disposed(by: self.disposeBag)
//        
//        // Bind output
//        viewModel.output.goToMain
//            .bind(to: goToMainExpectation)
//            .disposed(by: self.disposeBag)
//        
//        self.schedular.start()
//        
//        // Assert
//        XCTAssertEqual(goToMainExpectation.events.count, 1)
//    }
//    
//    func testValidateTokenFailAtLocal() {
//        // Setup
//        let goToSignInExpectation = self.schedular.createObserver(Void.self)
//        
//        self.remoteConfigServiceMock.fetchMinimalVersionObservable = .create { observer in
//            observer.onNext("1.0.0")
//            observer.onCompleted()
//            return Disposables.create()
//        }
//        
//        let viewModel = SplashViewModel(
//            userDefaults: self.userDefaults,
//            userService: self.userServiceMock,
//            remoteConfigService: self.remoteConfigServiceMock,
//            medalContext: MedalContext.shared,
//            medalService: self.medalServiceMock
//        )
//        
//        // Bind input
//        self.schedular.createColdObservable([.next(210, ())])
//            .bind(to: viewModel.input.viewDidLoad)
//            .disposed(by: self.disposeBag)
//        
//        // Bind output
//        viewModel.output.goToSignIn
//            .bind(to: goToSignInExpectation)
//            .disposed(by: self.disposeBag)
//        
//        self.schedular.start()
//        
//        // Assert
//        XCTAssertEqual(goToSignInExpectation.events.count, 1)
//    }
//    
//    func testValidateTokenFailWithUnauthorized() {
//        // Setup
//        let goToSignInWithAlertExpectation = self.schedular.createObserver(AlertContent.self)
//        
//        self.remoteConfigServiceMock.fetchMinimalVersionObservable = .create { observer in
//            observer.onNext("1.0.0")
//            observer.onCompleted()
//            return Disposables.create()
//        }
//        self.userDefaults.setUserToken(token: "test token")
//        self.userServiceMock.fetchUserInfoObservable = .create { observer in
//            observer.onError(HTTPError.unauthorized)
//            
//            return Disposables.create()
//        }
//        
//        let viewModel = SplashViewModel(
//            userDefaults: self.userDefaults,
//            userService: self.userServiceMock,
//            remoteConfigService: self.remoteConfigServiceMock,
//            medalContext: MedalContext.shared,
//            medalService: self.medalServiceMock
//        )
//        
//        // Bind input
//        self.schedular.createColdObservable([.next(210, ())])
//            .bind(to: viewModel.input.viewDidLoad)
//            .disposed(by: self.disposeBag)
//        
//        // Bind output
//        viewModel.output.goToSignInWithAlert
//            .bind(to: goToSignInWithAlertExpectation)
//            .disposed(by: self.disposeBag)
//        
//        self.schedular.start()
//        
//        // Assert
//        XCTAssertRecordedElements(
//            goToSignInWithAlertExpectation.events,
//            [AlertContent(httpError: HTTPError.unauthorized)]
//        )
//    }
//    
//    func testValidateTokenFailWithForbidden() {
//        // Setup
//        let goToSignInWithAlertExpectation = self.schedular.createObserver(AlertContent.self)
//        
//        self.remoteConfigServiceMock.fetchMinimalVersionObservable = .create { observer in
//            observer.onNext("1.0.0")
//            observer.onCompleted()
//            return Disposables.create()
//        }
//        self.userDefaults.setUserToken(token: "test token")
//        self.userServiceMock.fetchUserInfoObservable = .create { observer in
//            observer.onError(HTTPError.forbidden)
//            
//            return Disposables.create()
//        }
//        
//        let viewModel = SplashViewModel(
//            userDefaults: self.userDefaults,
//            userService: self.userServiceMock,
//            remoteConfigService: self.remoteConfigServiceMock,
//            medalContext: MedalContext.shared,
//            medalService: self.medalServiceMock
//        )
//        
//        // Bind input
//        self.schedular.createColdObservable([.next(210, ())])
//            .bind(to: viewModel.input.viewDidLoad)
//            .disposed(by: self.disposeBag)
//        
//        // Bind output
//        viewModel.output.goToSignInWithAlert
//            .bind(to: goToSignInWithAlertExpectation)
//            .disposed(by: self.disposeBag)
//        
//        self.schedular.start()
//        
//        // Assert
//        XCTAssertRecordedElements(
//            goToSignInWithAlertExpectation.events,
//            [AlertContent(httpError: HTTPError.forbidden)]
//        )
//    }
//    
//    func testValidateTokenFailWithMaintenance() {
//        // Setup
//        let showMaintenanceAlertExpectation = self.schedular.createObserver(AlertContent.self)
//        
//        self.remoteConfigServiceMock.fetchMinimalVersionObservable = .create { observer in
//            observer.onNext("1.0.0")
//            observer.onCompleted()
//            return Disposables.create()
//        }
//        self.userDefaults.setUserToken(token: "test token")
//        self.userServiceMock.fetchUserInfoObservable = .create { observer in
//            observer.onError(HTTPError.maintenance)
//            
//            return Disposables.create()
//        }
//        
//        let viewModel = SplashViewModel(
//            userDefaults: self.userDefaults,
//            userService: self.userServiceMock,
//            remoteConfigService: self.remoteConfigServiceMock,
//            medalContext: MedalContext.shared,
//            medalService: self.medalServiceMock
//        )
//        
//        // Bind input
//        self.schedular.createColdObservable([.next(210, ())])
//            .bind(to: viewModel.input.viewDidLoad)
//            .disposed(by: self.disposeBag)
//        
//        // Bind output
//        viewModel.output.showMaintenanceAlert
//            .bind(to: showMaintenanceAlertExpectation)
//            .disposed(by: self.disposeBag)
//        
//        self.schedular.start()
//        
//        // Assert
//        XCTAssertRecordedElements(
//            showMaintenanceAlertExpectation.events,
//            [AlertContent(httpError: HTTPError.maintenance)]
//        )
//    }
//    
//    func testValidateTokenFailWithUnknownError() {
//        let showErrorAlertExpectation = self.schedular.createObserver(Error.self)
//        
//        self.remoteConfigServiceMock.fetchMinimalVersionObservable = .create { observer in
//            observer.onNext("1.0.0")
//            observer.onCompleted()
//            return Disposables.create()
//        }
//        self.userDefaults.setUserToken(token: "test token")
//        self.userServiceMock.fetchUserInfoObservable = .create { observer in
//            observer.onError(BaseError.unknown)
//            
//            return Disposables.create()
//        }
//        
//        let viewModel = SplashViewModel(
//            userDefaults: self.userDefaults,
//            userService: self.userServiceMock,
//            remoteConfigService: self.remoteConfigServiceMock,
//            medalContext: MedalContext.shared,
//            medalService: self.medalServiceMock
//        )
//        
//        // Bind input
//        self.schedular.createColdObservable([.next(210, ())])
//            .bind(to: viewModel.input.viewDidLoad)
//            .disposed(by: self.disposeBag)
//        
//        // Bind output
//        viewModel.showErrorAlert
//            .bind(to: showErrorAlertExpectation)
//            .disposed(by: self.disposeBag)
//        
//        self.schedular.start()
//        
//        // Assert
//        XCTAssertEqual(showErrorAlertExpectation.events.count, 1)
//    }
}
