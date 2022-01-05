import RxSwift

@testable import dollar_in_my_pocket

struct MedalServiceMock: MedalServiceProtocol {
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
