import Foundation

protocol AdvertisementServiceProtocol {
    func fetchAdvertisements(input: FetchAdvertisementInput) async -> Result<[AdvertisementResponse], Error>
}

public struct AdvertisementService: AdvertisementServiceProtocol {
    func fetchAdvertisements(input: FetchAdvertisementInput) async -> Result<[AdvertisementResponse], Error> {
        let request = FetchAdvertisementRequest(input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
}
