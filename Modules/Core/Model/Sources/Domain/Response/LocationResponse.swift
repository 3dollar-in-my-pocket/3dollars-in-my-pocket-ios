import Foundation
import CoreLocation

public struct LocationResponse: Decodable, Hashable {
    public let latitude: Double
    public let longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

public extension LocationResponse {
    var toCLLocation: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}
