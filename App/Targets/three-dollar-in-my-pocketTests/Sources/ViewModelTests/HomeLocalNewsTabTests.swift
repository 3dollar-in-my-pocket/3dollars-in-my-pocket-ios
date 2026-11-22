import Combine
import CoreLocation
import XCTest

import Common
import Log
import Model
@testable import Home

@MainActor
final class HomeLocalNewsTabTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    private let location = CLLocation(latitude: 37.4979, longitude: 127.0276)
    private let newsTabIndex = 2

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: TH-1426 TC1

    func test_TH1426_TC1_NEWS를포함한3탭이오면_서버순서로노출하고_서버기본탭을선택한다() throws {
        // Given
        let viewModel = makeViewModel()

        // When
        viewModel.input.setTabSection.send(try makeTabSection())

        // Then
        let tabs = viewModel.output.tabs.value
        XCTAssertEqual(tabs.map(\.tab.tabId), ["DEFAULT", "CURATION", "NEWS"])
        XCTAssertEqual(tabs.map(\.tab.viewType), [.storeList, .curation, .news])
        XCTAssertEqual(tabs.map(\.isSelected), [true, false, false])
        XCTAssertEqual(viewModel.output.selectedViewType.value, .storeList)
    }

    // MARK: TH-1426 TC2

    func test_TH1426_TC2_동네소식탭을누르면_탭클릭로그후_지도좌표로소식을불러온다() throws {
        // Given
        let logManager = MockLogManager()
        let viewModel = makeViewModel(logManager: logManager)
        viewModel.input.setTabSection.send(try makeTabSection())
        viewModel.input.setSearchArea.send(HomeSearchArea(location: location, maxDistance: nil))
        var loadedAreas: [HomeSearchArea] = []
        viewModel.output.loadNews
            .sink { loadedAreas.append($0) }
            .store(in: &cancellables)

        // When
        viewModel.input.didTapTab.send(newsTabIndex)

        // Then
        XCTAssertEqual(viewModel.output.selectedViewType.value, .news)
        XCTAssertEqual(logManager.sentEvents.filter { $0.name == .click }.last?.parameters["value"] as? String, "NEWS")
        XCTAssertEqual(loadedAreas.map(\.latitude), [location.coordinate.latitude])
        XCTAssertEqual(loadedAreas.map(\.longitude), [location.coordinate.longitude])
    }

    // MARK: TH-1426 TC4

    func test_TH1426_TC4_동네소식탭에서지도좌표가바뀌면_새좌표로소식을다시불러온다() throws {
        // Given
        let viewModel = makeViewModel()
        viewModel.input.setTabSection.send(try makeTabSection())
        viewModel.input.setSearchArea.send(HomeSearchArea(location: location, maxDistance: nil))
        viewModel.input.didTapTab.send(newsTabIndex)
        var loadedLatitudes: [Double] = []
        viewModel.output.loadNews
            .sink { loadedLatitudes.append($0.latitude) }
            .store(in: &cancellables)

        // When
        viewModel.input.setSearchArea.send(HomeSearchArea(location: CLLocation(latitude: 37.5665, longitude: 126.9780), maxDistance: nil))

        // Then
        XCTAssertEqual(loadedLatitudes, [37.5665])
    }

    func test_TH1426_TC4_다른탭을보는동안에는_지도좌표가바뀌어도_소식을불러오지않는다() throws {
        // Given
        let viewModel = makeViewModel()
        viewModel.input.setTabSection.send(try makeTabSection())
        var loadCount = 0
        viewModel.output.loadNews
            .sink { _ in loadCount += 1 }
            .store(in: &cancellables)

        // When
        viewModel.input.setSearchArea.send(HomeSearchArea(location: location, maxDistance: nil))

        // Then
        XCTAssertEqual(loadCount, 0)
    }

    // MARK: TH-1426 TC10

    func test_TH1426_TC10_마지막으로본소식보다새소식이있으면_동네소식탭에빨간점이보인다() async throws {
        // Given
        let preference = makePreference(lastSeenFeedId: "6ad390b8279bd19eba6157f5")
        let viewModel = makeViewModel(feedRepository: try makeFeedRepository(), preference: preference)
        viewModel.input.setTabSection.send(try makeTabSection())

        // When
        viewModel.input.setSearchArea.send(HomeSearchArea(location: location, maxDistance: nil))

        // Then
        await waitForNewsBadge(viewModel, equals: true)
        XCTAssertEqual(viewModel.output.tabs.value.map(\.hasNewBadge), [false, false, true])
    }

    // MARK: TH-1426 TC11

    func test_TH1426_TC11_동네소식탭을열면_빨간점이사라지고_최신소식을본것으로저장한다() async throws {
        // Given
        let preference = makePreference(lastSeenFeedId: "6ad390b8279bd19eba6157f5")
        let viewModel = makeViewModel(feedRepository: try makeFeedRepository(), preference: preference)
        viewModel.input.setTabSection.send(try makeTabSection())
        viewModel.input.setSearchArea.send(HomeSearchArea(location: location, maxDistance: nil))
        await waitForNewsBadge(viewModel, equals: true)

        // When
        viewModel.input.didTapTab.send(newsTabIndex)

        // Then
        XCTAssertEqual(viewModel.output.tabs.value.map(\.hasNewBadge), [false, false, false])
        XCTAssertEqual(preference.lastSeenLocalNewsFeedId, "6ad7645103e011c1ebc9ffd5")
    }

    func test_TH1426_TC11_동네소식탭이선택된동안새소식을받아도_빨간점을보이지않는다() async throws {
        // Given
        let preference = makePreference(lastSeenFeedId: "6ad390b8279bd19eba6157f5")
        let feedRepository = try makeFeedRepository()
        let viewModel = makeViewModel(feedRepository: feedRepository, preference: preference)
        viewModel.input.setTabSection.send(try makeTabSection())
        viewModel.input.didTapTab.send(newsTabIndex)
        let updated = expectTabsUpdate(viewModel)

        // When
        viewModel.input.setSearchArea.send(HomeSearchArea(location: location, maxDistance: nil))

        // Then
        await fulfillment(of: [updated], timeout: 1)
        XCTAssertEqual(viewModel.output.tabs.value.map(\.hasNewBadge), [false, false, false])
        XCTAssertEqual(preference.lastSeenLocalNewsFeedId, "6ad7645103e011c1ebc9ffd5")
    }

    // MARK: TH-1426 TC12

    func test_TH1426_TC12_최신소식을이미봤으면_빨간점을보이지않는다() async throws {
        // Given
        let preference = makePreference(lastSeenFeedId: "6ad7645103e011c1ebc9ffd5")
        let feedRepository = try makeFeedRepository()
        let viewModel = makeViewModel(feedRepository: feedRepository, preference: preference)
        viewModel.input.setTabSection.send(try makeTabSection())
        let updated = expectTabsUpdate(viewModel)

        // When
        viewModel.input.setSearchArea.send(HomeSearchArea(location: location, maxDistance: nil))

        // Then
        await fulfillment(of: [updated], timeout: 1)
        XCTAssertEqual(viewModel.output.tabs.value.map(\.hasNewBadge), [false, false, false])
        XCTAssertEqual(feedRepository.requestedInputs.first?.size, 1)
    }

    // MARK: TH-1426 TC13

    func test_TH1426_TC13_동네소식을한번도열지않았고_소식이있으면_빨간점이보인다() async throws {
        // Given
        let viewModel = makeViewModel(feedRepository: try makeFeedRepository(), preference: makePreference(lastSeenFeedId: nil))
        viewModel.input.setTabSection.send(try makeTabSection())

        // When
        viewModel.input.setSearchArea.send(HomeSearchArea(location: location, maxDistance: nil))

        // Then
        await waitForNewsBadge(viewModel, equals: true)
    }

    func test_TH1426_TC13_지도영역에소식이없으면_빨간점을보이지않는다() async throws {
        // Given
        let feedRepository = MockFeedRepository()
        feedRepository.fetchFeedResults = [.success(try makeFeeds(contents: []))]
        let viewModel = makeViewModel(feedRepository: feedRepository, preference: makePreference(lastSeenFeedId: nil))
        viewModel.input.setTabSection.send(try makeTabSection())
        let updated = expectTabsUpdate(viewModel)

        // When
        viewModel.input.setSearchArea.send(HomeSearchArea(location: location, maxDistance: nil))

        // Then
        await fulfillment(of: [updated], timeout: 1)
        XCTAssertEqual(viewModel.output.tabs.value.map(\.hasNewBadge), [false, false, false])
    }

    // MARK: TH-1426 TC19

    func test_TH1426_TC19_서버가모르는viewType탭은_숨기고나머지탭은보여준다() throws {
        // Given
        let viewModel = makeViewModel()

        // When
        viewModel.input.setTabSection.send(try makeTabSection(appendingViewType: "RANKING"))

        // Then
        XCTAssertEqual(viewModel.output.tabs.value.map(\.tab.tabId), ["DEFAULT", "CURATION", "NEWS"])
    }

    // MARK: TH-1593 TC5

    func test_TH1593_TC5_새소식확인용최신피드조회에_지도반경이담긴다() async throws {
        // Given
        let feedRepository = try makeFeedRepository()
        let viewModel = makeViewModel(feedRepository: feedRepository, preference: makePreference(lastSeenFeedId: nil))
        viewModel.input.setTabSection.send(try makeTabSection())
        let updated = expectTabsUpdate(viewModel)

        // When
        viewModel.input.setSearchArea.send(HomeSearchArea(location: location, maxDistance: 4200))

        // Then
        await fulfillment(of: [updated], timeout: 1)
        XCTAssertEqual(feedRepository.requestedInputs.first?.size, 1)
        XCTAssertEqual(feedRepository.requestedInputs.first?.maxDistanceM, 4200)
    }

    // MARK: TH-1593 TC4

    func test_TH1593_TC4_동네소식탭을열면_지도반경과함께소식을불러온다() throws {
        // Given
        let viewModel = makeViewModel()
        viewModel.input.setTabSection.send(try makeTabSection())
        viewModel.input.setSearchArea.send(HomeSearchArea(location: location, maxDistance: 4200))
        var loaded: [HomeSearchArea] = []
        viewModel.output.loadNews
            .sink { loaded.append($0) }
            .store(in: &cancellables)

        // When
        viewModel.input.didTapTab.send(newsTabIndex)

        // Then
        XCTAssertEqual(loaded.map(\.maxDistance), [4200])
    }

    // MARK: TH-1613 TC1

    func test_TH1613_TC1_동네소식탭을누르면_소식섹션을조회하고_서버노출로그를보낸다() async throws {
        // Given
        let logManager = MockLogManager()
        let screenRepository = try makeNewsSectionRepository()
        let viewModel = makeViewModel(screenRepository: screenRepository, logManager: logManager)
        viewModel.input.setTabSection.send(try makeTabSection())
        viewModel.input.setSearchArea.send(HomeSearchArea(location: location, maxDistance: nil))

        // When
        viewModel.input.didTapTab.send(newsTabIndex)

        // Then
        await waitUntil { newsImpressions(logManager).count == 1 }
        XCTAssertEqual(screenRepository.fetchHomeNewsSectionTabIds, ["NEWS"])
        let event = try XCTUnwrap(newsImpressions(logManager).first)
        XCTAssertEqual(event.screen.rawValue, "home")
        XCTAssertEqual(event.parameters["object_type"] as? String, "section")
        XCTAssertEqual(event.parameters["tabId"] as? String, "NEWS")
    }

    // MARK: TH-1613 TC2

    func test_TH1613_TC2_같은지도영역에서동네소식탭에다시들어와도_노출로그를다시보내지않는다() async throws {
        // Given
        let logManager = MockLogManager()
        let screenRepository = try makeNewsSectionRepository()
        let viewModel = makeViewModel(screenRepository: screenRepository, logManager: logManager)
        viewModel.input.setTabSection.send(try makeTabSection())
        viewModel.input.setSearchArea.send(HomeSearchArea(location: location, maxDistance: nil))
        viewModel.input.didTapTab.send(newsTabIndex)
        await waitUntil { newsImpressions(logManager).count == 1 }

        // When
        viewModel.input.didTapTab.send(0)
        viewModel.input.didTapTab.send(newsTabIndex)
        try await Task.sleep(nanoseconds: 200_000_000)

        // Then
        XCTAssertEqual(screenRepository.fetchHomeNewsSectionTabIds, ["NEWS"])
        XCTAssertEqual(newsImpressions(logManager).count, 1)
    }

    // MARK: TH-1613 TC3

    func test_TH1613_TC3_동네소식탭에서지도영역이바뀌면_소식섹션노출로그를다시보낸다() async throws {
        // Given
        let logManager = MockLogManager()
        let screenRepository = try makeNewsSectionRepository()
        let viewModel = makeViewModel(screenRepository: screenRepository, logManager: logManager)
        viewModel.input.setTabSection.send(try makeTabSection())
        viewModel.input.setSearchArea.send(HomeSearchArea(location: location, maxDistance: nil))
        viewModel.input.didTapTab.send(newsTabIndex)
        await waitUntil { newsImpressions(logManager).count == 1 }

        // When
        viewModel.input.setSearchArea.send(HomeSearchArea(location: CLLocation(latitude: 37.5665, longitude: 126.9780), maxDistance: nil))

        // Then
        await waitUntil { newsImpressions(logManager).count == 2 }
        XCTAssertEqual(newsImpressions(logManager).count, 2)
        XCTAssertEqual(screenRepository.fetchHomeNewsSectionTabIds, ["NEWS", "NEWS"])
    }

    // MARK: TH-1613 TC4

    func test_TH1613_TC4_다른탭을보는동안에는_소식섹션을조회하지않는다() async throws {
        // Given
        let logManager = MockLogManager()
        let screenRepository = try makeNewsSectionRepository()
        let viewModel = makeViewModel(screenRepository: screenRepository, logManager: logManager)
        viewModel.input.setTabSection.send(try makeTabSection())

        // When
        viewModel.input.setSearchArea.send(HomeSearchArea(location: location, maxDistance: nil))
        try await Task.sleep(nanoseconds: 200_000_000)

        // Then
        XCTAssertTrue(screenRepository.fetchHomeNewsSectionTabIds.isEmpty)
        XCTAssertTrue(newsImpressions(logManager).isEmpty)
    }

    // MARK: TH-1613 TC5

    func test_TH1613_TC5_응답전에다른탭으로가면_노출로그를보류했다가_소식탭에돌아올때한번보낸다() async throws {
        // Given
        let logManager = MockLogManager()
        let screenRepository = MockScreenRepository()
        let response = try FixtureLoader.decode(HomeNewsSectionResponse.self, from: "HomeNewsSection")
        screenRepository.fetchHomeNewsSectionHandler = { _ in
            try? await Task.sleep(nanoseconds: 300_000_000)
            return .success(response)
        }
        let viewModel = makeViewModel(screenRepository: screenRepository, logManager: logManager)
        viewModel.input.setTabSection.send(try makeTabSection())
        viewModel.input.setSearchArea.send(HomeSearchArea(location: location, maxDistance: nil))
        viewModel.input.didTapTab.send(newsTabIndex)

        // When
        viewModel.input.didTapTab.send(0)
        try await Task.sleep(nanoseconds: 600_000_000)
        let impressionsWhileAway = newsImpressions(logManager).count
        viewModel.input.didTapTab.send(newsTabIndex)

        // Then
        XCTAssertEqual(impressionsWhileAway, 0)
        XCTAssertEqual(newsImpressions(logManager).count, 1)
        XCTAssertEqual(screenRepository.fetchHomeNewsSectionTabIds, ["NEWS"])
    }

    // MARK: TH-1613 TC6

    func test_TH1613_TC6_소식섹션조회가실패하면_같은지도영역이어도_다시들어올때재조회한다() async throws {
        // Given
        let logManager = MockLogManager()
        let screenRepository = MockScreenRepository()
        let response = try FixtureLoader.decode(HomeNewsSectionResponse.self, from: "HomeNewsSection")
        screenRepository.fetchHomeNewsSectionHandler = { callCount in
            callCount == 1 ? .failure(MockError.notStubbed()) : .success(response)
        }
        let viewModel = makeViewModel(screenRepository: screenRepository, logManager: logManager)
        viewModel.input.setTabSection.send(try makeTabSection())
        viewModel.input.setSearchArea.send(HomeSearchArea(location: location, maxDistance: nil))
        viewModel.input.didTapTab.send(newsTabIndex)
        await waitUntil { screenRepository.fetchHomeNewsSectionTabIds.count == 1 }
        try await Task.sleep(nanoseconds: 100_000_000)

        // When
        viewModel.input.didTapTab.send(0)
        viewModel.input.didTapTab.send(newsTabIndex)

        // Then
        await waitUntil { newsImpressions(logManager).count == 1 }
        XCTAssertEqual(newsImpressions(logManager).count, 1)
        XCTAssertEqual(screenRepository.fetchHomeNewsSectionTabIds, ["NEWS", "NEWS"])
    }

    // MARK: - Helpers

    private func makeViewModel(
        screenRepository: MockScreenRepository = MockScreenRepository(),
        feedRepository: MockFeedRepository = MockFeedRepository(),
        logManager: MockLogManager = MockLogManager(),
        preference: Preference = Preference(name: "HomeLocalNewsTabTests")
    ) -> HomeListViewModel {
        HomeListViewModel(dependency: .init(
            screenRepository: screenRepository,
            feedRepository: feedRepository,
            logManager: logManager,
            preference: preference
        ))
    }

    private func makeNewsSectionRepository() throws -> MockScreenRepository {
        let repository = MockScreenRepository()
        repository.fetchHomeNewsSectionResult = .success(try FixtureLoader.decode(HomeNewsSectionResponse.self, from: "HomeNewsSection"))
        return repository
    }

    private func newsImpressions(_ logManager: MockLogManager) -> [any LogEventType] {
        logManager.sentEvents.filter {
            $0.name.rawValue == EventName.impression.rawValue && $0.parameters["object_id"] as? String == "home_news"
        }
    }

    private func waitUntil(_ condition: () -> Bool) async {
        var attempts = 0
        while condition().isNot, attempts < 100 {
            attempts += 1
            try? await Task.sleep(nanoseconds: 20_000_000)
        }
    }

    private func makePreference(lastSeenFeedId: String?) -> Preference {
        let preference = Preference(name: "HomeLocalNewsTabTests")
        preference.lastSeenLocalNewsFeedId = lastSeenFeedId
        return preference
    }

    private func makeTabSection(appendingViewType viewType: String? = nil) throws -> HomeBottomSheetTabSection {
        var data = try fixtureData("HomeFilterScreenWithNewsTab")
        if let viewType {
            var json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
            var sections = try XCTUnwrap(json["sections"] as? [[String: Any]])
            let index = try XCTUnwrap(sections.firstIndex { $0["type"] as? String == "HOME_BOTTOM_SHEET_TAB" })
            var tabs = try XCTUnwrap(sections[index]["tabs"] as? [[String: Any]])
            var unknownTab = try XCTUnwrap(tabs.last)
            unknownTab["tabId"] = viewType
            unknownTab["viewType"] = viewType
            tabs.append(unknownTab)
            sections[index]["tabs"] = tabs
            json["sections"] = sections
            data = try JSONSerialization.data(withJSONObject: json)
        }
        let response = try JSONDecoder().decode(HomeFilterScreenResponse.self, from: data)
        return try XCTUnwrap(response.sections.compactMap { $0 as? HomeBottomSheetTabSection }.first)
    }

    private func makeFeedRepository() throws -> MockFeedRepository {
        let repository = MockFeedRepository()
        repository.fetchFeedResults = [.success(try FixtureLoader.decode(ContentsWithCursorResponse<FeedResponse>.self, from: "LocalNewsFeeds"))]
        return repository
    }

    private func makeFeeds(contents: [[String: Any]]) throws -> ContentsWithCursorResponse<FeedResponse> {
        let json: [String: Any] = ["contents": contents, "cursor": ["hasMore": false]]
        return try JSONDecoder().decode(
            ContentsWithCursorResponse<FeedResponse>.self,
            from: JSONSerialization.data(withJSONObject: json)
        )
    }

    private func fixtureData(_ fileName: String) throws -> Data {
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: fileName, withExtension: "json"))
        return try Data(contentsOf: url)
    }

    private func waitForNewsBadge(_ viewModel: HomeListViewModel, equals expected: Bool) async {
        let badge = expectation(description: "news badge")
        badge.assertForOverFulfill = false
        viewModel.output.tabs
            .filter { $0.contains { $0.tab.viewType == .news && $0.hasNewBadge == expected } }
            .sink { _ in badge.fulfill() }
            .store(in: &cancellables)
        await fulfillment(of: [badge], timeout: 3)
    }

    private func expectTabsUpdate(_ viewModel: HomeListViewModel) -> XCTestExpectation {
        let updated = expectation(description: "tabs updated")
        updated.assertForOverFulfill = false
        viewModel.output.tabs
            .dropFirst()
            .sink { _ in updated.fulfill() }
            .store(in: &cancellables)
        return updated
    }
}
