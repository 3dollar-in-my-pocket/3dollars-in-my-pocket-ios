import Foundation

import Networking

public struct Location {
    let latitude: Double
    let longitude: Double
    
    public init?(response: LocationResponse?) {
        guard let response = response else { return nil }
        self.latitude = response.latitude
        self.longitude = response.longitude
    }
}
