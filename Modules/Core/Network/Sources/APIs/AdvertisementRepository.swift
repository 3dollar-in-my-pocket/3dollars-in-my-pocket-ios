import Foundation

import Model

public protocol AdvertisementRepository {
    func fetchAdvertisements(input: FetchAdvertisementInput) async -> Result<AdvertisementListResponse, Error>
}

public struct AdvertisementRepositoryImpl: AdvertisementRepository {
    public init() { }
    
    public func fetchAdvertisements(input: FetchAdvertisementInput) async -> Result<AdvertisementListResponse, Error> {
        let request = AdvertisementApi.fetchAdvertisements(input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
}
