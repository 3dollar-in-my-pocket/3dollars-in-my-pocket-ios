import CoreLocation

struct HomeSearchArea: Equatable {
    let latitude: Double
    let longitude: Double
    let maxDistance: Double?

    init(location: CLLocation, maxDistance: Double?) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.maxDistance = maxDistance?.rounded()
    }
}
