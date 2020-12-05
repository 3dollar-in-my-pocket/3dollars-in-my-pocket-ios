import RxSwift

struct HomeViewModel {
    var nearestStore = BehaviorSubject<[StoreCard]>.init(value: [])
    var location = BehaviorSubject<(latitude: Double, longitude: Double)>.init(value: (37.505663, 127.05469426923472))
}
