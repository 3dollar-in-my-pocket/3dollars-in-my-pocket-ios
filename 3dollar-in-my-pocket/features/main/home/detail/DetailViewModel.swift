import RxSwift

struct DetailViewModel {
    var store = BehaviorSubject<Store?>.init(value: nil)
}
