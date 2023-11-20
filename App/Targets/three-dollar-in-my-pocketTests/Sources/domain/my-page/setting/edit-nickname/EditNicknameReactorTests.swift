import XCTest
import RxSwift
import RxTest

@testable import dollar_in_my_pocket

final class EditNicknameReactorTests: XCTestCase {
    var disposeBag: DisposeBag!
    var userService: UserServiceMock!
    var globalState: GlobalState!
    var schedular: TestScheduler!
    
    override func setUp() {
        super.setUp()
        
        self.disposeBag = DisposeBag()
        self.userService = UserServiceMock()
        self.globalState = GlobalState.shared
        self.schedular = TestScheduler(initialClock: 0)
    }
    
    override func tearDown() {
        super.tearDown()
        
        self.disposeBag = nil
        self.userService = nil
        self.globalState = nil
        self.schedular = nil
    }
    
    func testInputNickname() {
        // Given
        let nickname = "test nickname"
        let reactor = EditNicknameReactor(
            userService: self.userService,
            globalState: self.globalState
        )
        let nicknameExpectation = self.schedular.createObserver(String.self)
        let enableEditButtonExpectation = self.schedular.createObserver(Bool.self)
        
        // When
        self.schedular.createColdObservable([
            .next(210, EditNicknameReactor.Action.inputNickname(nickname))
        ])
        .bind(to: reactor.action)
        .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.nickname }
            .distinctUntilChanged()
            .bind(to: nicknameExpectation)
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.isEnableEditButton }
            .distinctUntilChanged()
            .bind(to: enableEditButtonExpectation)
            .disposed(by: self.disposeBag)
        
        self.schedular.start()
        
        // Then
        XCTAssertRecordedElements(nicknameExpectation.events, ["", nickname])
        XCTAssertRecordedElements(enableEditButtonExpectation.events, [false, true])
    }
    
    func testDeleteNickname() {
        // Given
        let initialNickname = "test nickname"
        let newNickname = ""
        let reactor = EditNicknameReactor(
            userService: self.userService,
            globalState: self.globalState,
            state: .init(
                nickname: initialNickname,
                isEnableEditButton: true,
                isHiddenWarning: true
            )
        )
        let nicknameExpectation = self.schedular.createObserver(String.self)
        let enableEditButtonExpectation = self.schedular.createObserver(Bool.self)
        
        // When
        self.schedular.createColdObservable([
            .next(210, EditNicknameReactor.Action.inputNickname(newNickname))
        ])
        .bind(to: reactor.action)
        .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.nickname }
            .distinctUntilChanged()
            .bind(to: nicknameExpectation)
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.isEnableEditButton }
            .distinctUntilChanged()
            .bind(to: enableEditButtonExpectation)
            .disposed(by: self.disposeBag)
        
        self.schedular.start()
        
        // Then
        XCTAssertRecordedElements(nicknameExpectation.events, [initialNickname, newNickname])
        XCTAssertRecordedElements(enableEditButtonExpectation.events, [true, false])
    }
    
    func testEditNicknameSuccess() {
        // Given
        self.userService.editNicknameObservable = .create { observer in
            observer.onNext(())
            observer.onCompleted()
            
            return Disposables.create()
        }
        
        let reactor = EditNicknameReactor(
            userService: self.userService,
            globalState: self.globalState,
            state: .init(nickname: "nickname", isEnableEditButton: true, isHiddenWarning: true)
        )
        let popExpectation = self.schedular.createObserver(Void.self)
        
        // When
        self.schedular.createColdObservable([
            .next(210, EditNicknameReactor.Action.tapEditNickname)
        ])
        .bind(to: reactor.action)
        .disposed(by: self.disposeBag)
        
        reactor.pulse(\.$pop)
            .compactMap { $0 }
            .bind(to: popExpectation)
            .disposed(by: self.disposeBag)
        
        self.schedular.start()
        
        // Then
        XCTAssertEqual(popExpectation.events.count, 1)
    }
    
    func testEditNicknameFailWithAlreadyExistedNickname() {
        // Given
        self.userService.editNicknameObservable = .create { observer in
            observer.onError(EditNicknameError.alreadyExistedNickname)
            
            return Disposables.create()
        }
        
        let reactor = EditNicknameReactor(
            userService: self.userService,
            globalState: self.globalState,
            state: .init(nickname: "nickname", isEnableEditButton: true, isHiddenWarning: true)
        )
        let hiddenWarningExpectation = self.schedular.createObserver(Bool.self)
        let popExpectation = self.schedular.createObserver(Void.self)
        
        // When
        self.schedular.createColdObservable([
            .next(210, EditNicknameReactor.Action.tapEditNickname)
        ])
        .bind(to: reactor.action)
        .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.isHiddenWarning }
            .distinctUntilChanged()
            .bind(to: hiddenWarningExpectation)
            .disposed(by: self.disposeBag)
        
        reactor.pulse(\.$pop)
            .compactMap { $0 }
            .bind(to: popExpectation)
            .disposed(by: self.disposeBag)
        
        self.schedular.start()
        
        // Then
        XCTAssertEqual(popExpectation.events.count, 0)
        XCTAssertRecordedElements(hiddenWarningExpectation.events, [true, false])
    }
    
    func testEditNicknameFailWithBadReqeust() {
        // Given
        self.userService.editNicknameObservable = .create { observer in
            observer.onError(EditNicknameError.badRequest)
            
            return Disposables.create()
        }
        
        let reactor = EditNicknameReactor(
            userService: self.userService,
            globalState: self.globalState,
            state: .init(nickname: "nickname", isEnableEditButton: true, isHiddenWarning: true)
        )
        let hiddenWarningExpectation = self.schedular.createObserver(Bool.self)
        let popExpectation = self.schedular.createObserver(Void.self)
        let showErrorAlertExpectation = self.schedular.createObserver(Error.self)
        
        // When
        self.schedular.createColdObservable([
            .next(210, EditNicknameReactor.Action.tapEditNickname)
        ])
        .bind(to: reactor.action)
        .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.isHiddenWarning }
            .distinctUntilChanged()
            .bind(to: hiddenWarningExpectation)
            .disposed(by: self.disposeBag)
        
        reactor.pulse(\.$pop)
            .compactMap { $0 }
            .bind(to: popExpectation)
            .disposed(by: self.disposeBag)
        
        reactor.showErrorAlertPublisher
            .bind(to: showErrorAlertExpectation)
            .disposed(by: self.disposeBag)
        
        self.schedular.start()
        
        // Then
        XCTAssertEqual(popExpectation.events.count, 0)
        XCTAssertRecordedElements(hiddenWarningExpectation.events, [true])
        XCTAssertEqual(showErrorAlertExpectation.events.count, 1)
    }
    
    func testEditNicknameFail() {
        // Given
        self.userService.editNicknameObservable = .create { observer in
            observer.onError(BaseError.custom("에러 발생"))
            
            return Disposables.create()
        }
        
        let reactor = EditNicknameReactor(
            userService: self.userService,
            globalState: self.globalState,
            state: .init(nickname: "nickname", isEnableEditButton: true, isHiddenWarning: true)
        )
        let hiddenWarningExpectation = self.schedular.createObserver(Bool.self)
        let popExpectation = self.schedular.createObserver(Void.self)
        let showErrorAlertExpectation = self.schedular.createObserver(Error.self)
        
        // When
        self.schedular.createColdObservable([
            .next(210, EditNicknameReactor.Action.tapEditNickname)
        ])
        .bind(to: reactor.action)
        .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.isHiddenWarning }
            .distinctUntilChanged()
            .bind(to: hiddenWarningExpectation)
            .disposed(by: self.disposeBag)
        
        reactor.pulse(\.$pop)
            .compactMap { $0 }
            .bind(to: popExpectation)
            .disposed(by: self.disposeBag)
        
        reactor.showErrorAlertPublisher
            .bind(to: showErrorAlertExpectation)
            .disposed(by: self.disposeBag)
        
        self.schedular.start()
        
        // Then
        XCTAssertEqual(popExpectation.events.count, 0)
        XCTAssertRecordedElements(hiddenWarningExpectation.events, [true])
        XCTAssertEqual(showErrorAlertExpectation.events.count, 1)
    }
}
