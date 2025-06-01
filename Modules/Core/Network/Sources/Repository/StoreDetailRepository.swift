import Foundation

import Model

public protocol StoreDetailRepository {
    func fetchStoreDetail(storeId: String) async -> Result<StoreScreenResponse, Error>
}

public final class StoreDetailRepositoryImpl: StoreDetailRepository {
    public init()  { }
    
    public func fetchStoreDetail(storeId: String) async -> Result<StoreScreenResponse, Error> {
        return await NetworkManager.shared.request(requestType: StoreDetailApi.fetchStoreDetail(storeId: storeId))
    }
}
