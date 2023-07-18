import Foundation

public protocol AdvertisementServiceProtocol {
    func fetchAdvertisements(input: FetchAdvertisementInput) async -> Result<[AdvertisementResponse], Error>
}

public struct AdvertisementService: AdvertisementServiceProtocol {
    public init() { }
    
    public func fetchAdvertisements(input: FetchAdvertisementInput) async -> Result<[AdvertisementResponse], Error> {
        let request = FetchAdvertisementRequest(input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
}
