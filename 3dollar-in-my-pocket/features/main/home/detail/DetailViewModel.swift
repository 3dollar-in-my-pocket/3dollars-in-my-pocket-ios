import RxSwift

struct DetailViewModel {
    var store = BehaviorSubject<Store?>.init(value: nil)
    var location: (latitude: Double, longitude: Double) = (0 , 0) 
}
