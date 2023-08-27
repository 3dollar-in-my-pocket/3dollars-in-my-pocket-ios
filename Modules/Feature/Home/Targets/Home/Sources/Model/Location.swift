import Foundation

import Model

struct Location {
    let latitude: Double
    let longitude: Double
    
    init?(response: LocationResponse?) {
        guard let response = response else { return nil }
        self.latitude = response.latitude
        self.longitude = response.longitude
    }
}
