import RxSwift

@testable import dollar_in_my_pocket

struct MedalServiceMock: MedalServiceProtocol {
    func fetchMyMedals() -> RxSwift.Observable<[dollar_in_my_pocket.Medal]> {
        return .empty()
    }
    
    func changeMyMedal(medalId: Int) -> RxSwift.Observable<dollar_in_my_pocket.User> {
        return .empty()
    }
    
    func fetchMedals() -> Observable<[MedalResponse]> {
        return .empty()
    }
    
    func fetchMyMedals() -> Observable<[MedalResponse]> {
        return .empty()
    }
    
    func changeMyMdal(medalId: Int) -> Observable<UserInfoResponse> {
        return .empty()
    }
}
