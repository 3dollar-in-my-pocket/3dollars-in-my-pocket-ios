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
}
