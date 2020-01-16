import RxSwift
import GoogleMaps

struct HomeViewModel {
    var nearestStore = BehaviorSubject<[StoreCard]>.init(value: [])
    var markers: [GMSMarker] = []
}
