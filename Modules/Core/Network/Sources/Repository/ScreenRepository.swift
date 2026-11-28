import Foundation

import Model

public protocol ScreenRepository {
    func fetchHomeFilterScreen(input: FetchHomeFilterScreenInput) async -> Result<HomeFilterScreenResponse, Error>
    func fetchHomeSectionList(input: FetchHomeSectionListInput) async -> Result<HomeListSectionResponse, Error>
    func fetchHomeCurationSection(
        curationTabId: String,
        input: FetchHomeCurationSectionInput
    ) async -> Result<HomeCurationSectionResponse, Error>
    func fetchHomeCurationCarouselCards(
        curationTabId: String,
        carouselId: String,
        input: FetchHomeCurationCarouselCardsInput
    ) async -> Result<HomeCurationCarouselCardsResponse, Error>
    func fetchHomeNewsSection(newsTabId: String) async -> Result<HomeNewsSectionResponse, Error>
    func getBottomNavigation() async -> Result<BottomNavigationResponse, Error>
}

public final class ScreenRepositoryImpl: ScreenRepository {
    public init() { }

    public func fetchHomeFilterScreen(input: FetchHomeFilterScreenInput) async -> Result<HomeFilterScreenResponse, Error> {
        let request = ScreenApi.fetchHomeFilterScreen(input: input)
        return await NetworkManager.shared.request(requestType: request)
    }

    public func fetchHomeSectionList(input: FetchHomeSectionListInput) async -> Result<HomeListSectionResponse, Error> {
        let request = ScreenApi.fetchHomeSectionList(input: input)
        return await NetworkManager.shared.request(requestType: request)
    }

    public func fetchHomeCurationSection(
        curationTabId: String,
        input: FetchHomeCurationSectionInput
    ) async -> Result<HomeCurationSectionResponse, Error> {
        let request = ScreenApi.fetchHomeCurationSection(curationTabId: curationTabId, input: input)
        return await NetworkManager.shared.request(requestType: request)
    }

    public func fetchHomeCurationCarouselCards(
        curationTabId: String,
        carouselId: String,
        input: FetchHomeCurationCarouselCardsInput
    ) async -> Result<HomeCurationCarouselCardsResponse, Error> {
        let request = ScreenApi.fetchHomeCurationCarouselCards(
            curationTabId: curationTabId,
            carouselId: carouselId,
            input: input
        )
        return await NetworkManager.shared.request(requestType: request)
    }

    public func fetchHomeNewsSection(newsTabId: String) async -> Result<HomeNewsSectionResponse, Error> {
        let request = ScreenApi.fetchHomeNewsSection(newsTabId: newsTabId)
        return await NetworkManager.shared.request(requestType: request)
    }

    public func getBottomNavigation() async -> Result<BottomNavigationResponse, Error> {
        let request = ScreenApi.getBottomNavigation
        return await NetworkManager.shared.request(requestType: request)
    }
}
