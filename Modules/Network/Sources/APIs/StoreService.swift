import Foundation
import CoreLocation

public protocol StoreServiceProtocol {
    func isStoresExistedAround(distance: Double, mapLocation: CLLocation) async -> Result<Bool, Error>
}

public struct StoreService: StoreServiceProtocol {
    public init() { }
    
    public func isStoresExistedAround(distance: Double, mapLocation: CLLocation) async -> Result<Bool, Error> {
        let request = IsStoreExistNearbyRequest(distance: distance, mapLocation: mapLocation)
        
        return await NetworkManager.shared.request(requestType: request)
    }
}
