import RxSwift

struct MyPageViewModel {
    var reportedStores = BehaviorSubject<[Store?]>.init(value: [])
    var reportedReviews = BehaviorSubject<[Review]>.init(value: [])
}
