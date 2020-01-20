import RxSwift

struct MyPageViewModel {
    var reportedStores = BehaviorSubject<[Store?]>.init(value: [])
    var reportedRevies = BehaviorSubject<[Review]>.init(value: [])
}
