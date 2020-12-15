import RxSwift

struct HomeViewModel {
  var nearestStore = BehaviorSubject<[StoreCard]>.init(value: [])
  var location = PublishSubject<(latitude: Double, longitude: Double)>()
}
