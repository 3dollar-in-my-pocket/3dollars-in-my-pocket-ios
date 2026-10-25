import Combine
import CoreLocation
import XCTest

import Common
import Log
import Model
@testable import Home

final class AdCardViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: TH-1528 TC8

    func test_TH1528_TC8_홈리스트광고카드를탭하면_클릭로그1건후_링크로이동한다() async throws {
        // Given
        let logManager = MockLogManager()
        let response = try FixtureLoader.decode(HomeListSectionResponse.self, from: "HomeListSectionWithAdCard")
        let viewModel = makeHomeViewModel(logManager: logManager, response: response)
        await loadFirstPage(viewModel)
        var links: [SDLink] = []
        viewModel.output.route
            .sink { route in
                if case .deepLink(let link) = route { links.append(link) }
            }
            .store(in: &cancellables)

        // When
        viewModel.input.bottomSheetDidTapCard.send(2)

        // Then
        let clickLogs = logManager.sentEvents.filter { $0.name == .click }
        XCTAssertEqual(clickLogs.count, 1)
        XCTAssertEqual(clickLogs.first?.parameters["object_id"] as? String, "advertisement")
        XCTAssertEqual(links.map(\.link), ["https://web.threedollars.co.kr"])
        XCTAssertEqual(links.first?.type, .web)
    }

    // MARK: TH-1528 TC14

    func test_TH1528_TC14_링크가없는홈리스트광고카드를탭하면_클릭로그만보내고_이동하지않는다() async throws {
        // Given
        let logManager = MockLogManager()
        let response = try JSONDecoder().decode(HomeListSectionResponse.self, from: Data(Self.adCardWithoutLinkJson.utf8))
        let viewModel = makeHomeViewModel(logManager: logManager, response: response)
        await loadFirstPage(viewModel)
        var routeCount = 0
        viewModel.output.route
            .sink { _ in routeCount += 1 }
            .store(in: &cancellables)

        // When
        viewModel.input.bottomSheetDidTapCard.send(0)

        // Then
        XCTAssertEqual(logManager.sentEvents.filter { $0.name == .click }.count, 1)
        XCTAssertEqual(routeCount, 0)
    }

    // MARK: TH-1528 TC10

    func test_TH1528_TC10_홈리스트광고카드가보이면_광고노출로그를보낸다() throws {
        // Given
        let logManager = MockLogManager()
        let response = try FixtureLoader.decode(HomeListSectionResponse.self, from: "HomeListSectionWithAdCard")
        let viewModel = HomeListViewModel(dependency: .init(screenRepository: MockScreenRepository(), storeRepository: MockStoreRepository(), logManager: logManager))
        viewModel.input.updateCards.send(response.cards)

        // When
        viewModel.input.willDisplay.send(2)

        // Then
        let impression = try XCTUnwrap(logManager.sentEvents.last)
        XCTAssertEqual(impression.name, .impression)
        XCTAssertEqual(impression.parameters["object_id"] as? String, "advertisement")
    }

    func test_TH1528_TC10_큐레이션광고카드는_여러번보여도_노출로그를한번만보내고_탭하면클릭로그후링크로이동한다() async throws {
        // Given
        let logManager = MockLogManager()
        let repository = MockScreenRepository()
        repository.fetchHomeCurationSectionResult = .success(
            try FixtureLoader.decode(HomeCurationSectionResponse.self, from: "HomeCurationSectionWithAdCard")
        )
        let viewModel = HomeCurationViewModel(dependency: .init(
            screenRepository: repository,
            storeRepository: MockStoreRepository(),
            logManager: logManager
        ))
        let loaded = expectation(description: "items")
        loaded.assertForOverFulfill = false
        viewModel.output.items
            .dropFirst()
            .sink { _ in loaded.fulfill() }
            .store(in: &cancellables)
        var links: [SDLink] = []
        viewModel.output.route
            .sink { route in
                if case .deepLink(let link) = route { links.append(link) }
            }
            .store(in: &cancellables)
        viewModel.input.setTabId.send("CURATION")
        viewModel.input.setLocation.send(CLLocation(latitude: 37.4979, longitude: 127.0276))
        await fulfillment(of: [loaded], timeout: 1)
        let sentBefore = logManager.sentEvents.count

        // When
        viewModel.input.willDisplayCarouselCard.send((carouselId: "POPULAR_SNACKS", cardId: "AD:110"))
        viewModel.input.willDisplayCarouselCard.send((carouselId: "POPULAR_SNACKS", cardId: "AD:110"))
        viewModel.input.didTapCarouselCard.send((carouselId: "POPULAR_SNACKS", cardId: "AD:110"))

        // Then
        let events = logManager.sentEvents.dropFirst(sentBefore)
        XCTAssertEqual(events.map(\.name), [.impression, .click])
        XCTAssertEqual(events.map { $0.parameters["object_id"] as? String }, ["advertisement", "advertisement"])
        XCTAssertEqual(links.map(\.link), ["https://web.threedollars.co.kr"])
    }
}

extension AdCardViewModelTests {
    private static let adCardWithoutLinkJson = """
    {
        "cards": [
            {
                "type": "AD_CARD",
                "cardId": "AD:1",
                "labels": [],
                "clickLog": { "screenName": "home", "objectType": "card", "objectId": "advertisement", "extraParameters": {}, "eventType": "CLICK" },
                "impressionLog": { "screenName": "home", "objectType": "card", "objectId": "advertisement", "extraParameters": {}, "eventType": "IMPRESSION" }
            }
        ]
    }
    """

    private func makeHomeViewModel(logManager: MockLogManager, response: HomeListSectionResponse) -> HomeViewModel {
        HomeViewModel(dependency: .init(
            screenRepository: MockScreenRepository(fetchHomeSectionListResult: .success(response)),
            advertisementRepository: MockAdvertisementRepository(),
            userRepository: MockUserRepository(),
            mapRepository: MockMapRepository(),
            locationManager: MockLocationManager(),
            preference: Preference(name: "AdCardViewModelTests"),
            logManager: logManager
        ))
    }

    private func loadFirstPage(_ viewModel: HomeViewModel) async {
        let firstPage = expectation(description: "firstPage")
        viewModel.output.bottomSheetCardsReplaced
            .first()
            .sink { firstPage.fulfill() }
            .store(in: &cancellables)
        viewModel.input.onInitialMapDistanceReady.send(1000)
        await fulfillment(of: [firstPage], timeout: 1)
    }
}
