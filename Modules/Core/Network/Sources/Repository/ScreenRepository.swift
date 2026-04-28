import Foundation

import Model

public protocol ScreenRepository {
    func fetchHomeFilterScreen() async -> Result<HomeFilterScreenResponse, Error>
}

public final class ScreenRepositoryImpl: ScreenRepository {
    public init() { }

    public func fetchHomeFilterScreen() async -> Result<HomeFilterScreenResponse, Error> {
        let request = ScreenApi.fetchHomeFilterScreen
        return await NetworkManager.shared.request(requestType: request)
    }
}
