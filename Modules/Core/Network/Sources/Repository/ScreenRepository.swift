import Foundation

import Model

public protocol ScreenRepository {
    func fetchHomeFilterScreen() async -> Result<HomeFilterScreenResponse, Error>
    func fetchHomeSectionList(input: FetchHomeSectionListInput) async -> Result<HomeListSectionResponse, Error>
}

public final class ScreenRepositoryImpl: ScreenRepository {
    public init() { }

    public func fetchHomeFilterScreen() async -> Result<HomeFilterScreenResponse, Error> {
        let request = ScreenApi.fetchHomeFilterScreen
        return await NetworkManager.shared.request(requestType: request)
    }

    public func fetchHomeSectionList(input: FetchHomeSectionListInput) async -> Result<HomeListSectionResponse, Error> {
        let request = ScreenApi.fetchHomeSectionList(input: input)
        return await NetworkManager.shared.request(requestType: request)
    }
}
