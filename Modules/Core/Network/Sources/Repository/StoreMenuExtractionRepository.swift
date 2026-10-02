import Foundation

import Model

public protocol StoreMenuExtractionRepository {
    func extractStoreMenus(image: Data) async -> Result<StoreMenuExtractionListResponse, Error>
}

public struct StoreMenuExtractionRepositoryImpl: StoreMenuExtractionRepository {
    public init() { }

    public func extractStoreMenus(image: Data) async -> Result<StoreMenuExtractionListResponse, Error> {
        let request = StoreMenuExtractionRequest(image: image)
        return await NetworkManager.shared.request(requestType: request)
    }
}
