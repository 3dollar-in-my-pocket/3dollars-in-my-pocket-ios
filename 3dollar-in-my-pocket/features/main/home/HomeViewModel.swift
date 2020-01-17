import RxSwift
import GoogleMaps

struct HomeViewModel {
    var nearestStore = BehaviorSubject<[StoreCard]>.init(value: [])
    var markers: [GMSMarker] = []
    var location = BehaviorSubject<(latitude: Double, longitude: Double)>.init(value: (37.505663, 127.05469426923472))
}
