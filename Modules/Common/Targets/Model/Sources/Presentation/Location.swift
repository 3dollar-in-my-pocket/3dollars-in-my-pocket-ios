import Foundation

public struct Location: Hashable {
    public let latitude: Double
    public let longitude: Double
    
    public init?(response: LocationResponse?) {
        guard let response = response else { return nil }
        self.latitude = response.latitude
        self.longitude = response.longitude
    }
    
    public init(response: LocationResponse) {
        self.latitude = response.latitude
        self.longitude = response.longitude
    }
}
