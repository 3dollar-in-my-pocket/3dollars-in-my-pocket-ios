import Foundation
import CoreLocation
import Combine

public protocol StoreServiceProtocol {
    func isStoresExistedAround(distance: Double, mapLocation: CLLocation) -> AnyPublisher<Bool, Error>
}

public struct StoreService: StoreServiceProtocol {
    public func isStoresExistedAround(distance: Double, mapLocation: CLLocation) -> AnyPublisher<Bool, Error> {
        let request = IsStoreExistNearbyRequest(distance: distance, mapLocation: mapLocation)
        
        return NetworkManager(config: <#T##NetworkConfiguration#>)
    }
}
