import Foundation

import Model

public protocol HomeRepository {
    func fetchHomeCards(input: FetchHomeCardInput) async -> Result<HomeScreenResponse, Error>
}

public final class HomeRepositoryImpl: HomeRepository {
    public init() { }
    
    public func fetchHomeCards(input: FetchHomeCardInput) async -> Result<HomeScreenResponse, Error> {
        let request = HomeApi.fetchHomeCards(input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
}
