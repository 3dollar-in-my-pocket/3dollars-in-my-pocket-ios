import Foundation
import CoreLocation

public protocol StoreServiceProtocol {
    func isStoresExistedAround(distance: Double, mapLocation: CLLocation) async -> Result<IsStoresExistedAroundResponse, Error>
    
    func createStore(input: StoreCreateRequestInput) async -> Result<StoreCategoryResponse, Error>
}

public struct StoreService: StoreServiceProtocol {
    public init() { }
    
    public func isStoresExistedAround(distance: Double, mapLocation: CLLocation) async -> Result<IsStoresExistedAroundResponse, Error> {
        let request = IsStoreExistNearbyRequest(distance: distance, mapLocation: mapLocation)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func createStore(input: StoreCreateRequestInput) async -> Result<StoreCategoryResponse, Error> {
        let request = StoreCreateRequest(requestInput: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
}
