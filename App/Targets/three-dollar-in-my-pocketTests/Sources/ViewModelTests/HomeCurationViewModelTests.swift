import Combine
import CoreLocation
import XCTest

import Log
import Model
@testable import Home

final class HomeCurationViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    private let location = CLLocation(latitude: 37.497941, longitude: 127.027616)

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: TH-1402 TC4

    func test_TH1402_TC4_탭과위치가정해지면_섹션을조회해_아이템을서버순서대로전달한다() async throws {
        // Given
        let repository = MockScreenRepository()
        repository.fetchHomeCurationSectionResult = .success(try makeSection())
        let viewModel = makeViewModel(repository: repository)
        let items = expectItems(viewModel, count: 1)

        // When
        viewModel.input.setTabId.send("CURATION")
        viewModel.input.setLocation.send(location)

        // Then
        await fulfillment(of: [items.expectation], timeout: 1)
        let received = try items.last.unwrapped()
        let admobItemId = try Self.firstAdmobItemId(try makeSection()).unwrapped()
        XCTAssertEqual(received.map(\.identifier), [
            .carousel(carouselId: "POPULAR_SNACKS"),
            .admobCard(cardId: admobItemId),
            .carousel(carouselId: "TASTE_SNACKS")
        ])
        XCTAssertEqual(repository.fetchHomeCurationSectionCalls.map(\.curationTabId), ["CURATION"])
        XCTAssertEqual(repository.fetchHomeCurationSectionCalls.first?.input.mapLatitude, 37.497941)
        XCTAssertEqual(repository.fetchHomeCurationSectionCalls.first?.input.mapLongitude, 127.027616)
    }

    func test_TH1402_TC4_각캐러셀은_기본카테고리칩만선택되고_응답카드를그대로보여준다() async throws {
        // Given
        let section = try makeSection()
        let repository = MockScreenRepository()
        repository.fetchHomeCurationSectionResult = .success(section)
        let viewModel = makeViewModel(repository: repository)
        let items = expectItems(viewModel, count: 1)

        // When
        viewModel.input.setTabId.send("CURATION")
        viewModel.input.setLocation.send(location)

        // Then
        await fulfillment(of: [items.expectation], timeout: 1)
        let received = try items.last.unwrapped()
        let carousels = received.compactMap(Self.carousel)
        let responseCarousels = section.items.compactMap(Self.responseCarousel)
        XCTAssertEqual(carousels.count, 2)
        for (carousel, response) in zip(carousels, responseCarousels) {
            XCTAssertEqual(carousel.categories.filter(\.isSelected).map(\.filter.categoryId), [response.defaultCategoryId])
            XCTAssertEqual(carousel.cards, response.cards)
        }
    }

    func test_TH1402_TC4_위치가없으면_섹션을조회하지않는다() async {
        // Given
        let repository = MockScreenRepository()
        let viewModel = makeViewModel(repository: repository)

        // When
        viewModel.input.setTabId.send("CURATION")
        await Task.yield()

        // Then
        XCTAssertTrue(repository.fetchHomeCurationSectionCalls.isEmpty)
    }

    // MARK: TH-1402 TC5

    func test_TH1402_TC5_다른칩을누르면_클릭로그를보내고_해당캐러셀카드만교체한다() async throws {
        // Given
        let logManager = MockLogManager()
        let repository = MockScreenRepository()
        repository.fetchHomeCurationSectionResult = .success(try makeSection())
        let newCards = try FixtureLoader.decode(HomeCurationCarouselCardsResponse.self, from: "HomeCurationCarouselCards")
        repository.fetchHomeCurationCarouselCardsResult = .success(newCards)
        let viewModel = makeViewModel(repository: repository, logManager: logManager)
        let loaded = expectItems(viewModel, count: 1)
        viewModel.input.setTabId.send("CURATION")
        viewModel.input.setLocation.send(location)
        await fulfillment(of: [loaded.expectation], timeout: 1)
        let before = try loaded.last.unwrapped()
        let replaced = expectItems(viewModel, count: 2)

        // When
        viewModel.input.didTapCategory.send((carouselId: "POPULAR_SNACKS", categoryId: "FRUIT_SANDO"))

        // Then
        await fulfillment(of: [replaced.expectation], timeout: 1)
        let after = try replaced.last.unwrapped()
        let popular = try Self.carousel(after[0]).unwrapped()
        XCTAssertEqual(popular.selectedCategoryId, "FRUIT_SANDO")
        XCTAssertEqual(popular.categories.filter(\.isSelected).map(\.filter.categoryId), ["FRUIT_SANDO"])
        XCTAssertEqual(popular.cards.map(\.cardId), ["S:12805610", "S:12805286"])
        XCTAssertEqual(Self.carousel(after[2]), Self.carousel(before[2]))

        let call = try repository.fetchHomeCurationCarouselCardsCalls.first.unwrapped()
        XCTAssertEqual(call.curationTabId, "CURATION")
        XCTAssertEqual(call.carouselId, "POPULAR_SNACKS")
        XCTAssertEqual(call.input.categoryId, "FRUIT_SANDO")

        XCTAssertEqual(logManager.sentEvents.count, 1)
        let log = try logManager.sentEvents.first.unwrapped()
        XCTAssertEqual(log.name.rawValue, EventName.click.rawValue)
        XCTAssertEqual(log.parameters["object_type"] as? String, "button")
        XCTAssertEqual(log.parameters["object_id"] as? String, "category_filter")
        XCTAssertEqual(log.parameters["categoryId"] as? String, "FRUIT_SANDO")
        XCTAssertEqual(log.parameters["carouselId"] as? String, "POPULAR_SNACKS")
    }

    // MARK: TH-1402 TC6

    func test_TH1402_TC6_가게카드를누르면_가게정보가담긴클릭로그후_가게위치와함께가게선택을전달한다() async throws {
        // Given
        let logManager = MockLogManager()
        let repository = MockScreenRepository()
        repository.fetchHomeCurationSectionResult = .success(try makeSection())
        let storeRepository = MockStoreRepository()
        storeRepository.fetchStoreResult = .success(
            try FixtureLoader.decode(StoreDetailResponse.self, from: "StoreDetailUserStore")
        )
        let viewModel = makeViewModel(repository: repository, storeRepository: storeRepository, logManager: logManager)
        let loaded = expectItems(viewModel, count: 1)
        viewModel.input.setTabId.send("CURATION")
        viewModel.input.setLocation.send(location)
        await fulfillment(of: [loaded.expectation], timeout: 1)
        let selected = expectation(description: "didSelectStore")
        var selectedStore: HomeCurationSelectedStore?
        viewModel.output.didSelectStore
            .sink { store in
                selectedStore = store
                selected.fulfill()
            }
            .store(in: &cancellables)
        var routedLink: SDLink?
        viewModel.output.route
            .sink { route in
                if case .deepLink(let link) = route { routedLink = link }
            }
            .store(in: &cancellables)

        // When
        viewModel.input.didTapCarouselCard.send((carouselId: "POPULAR_SNACKS", cardId: "S:116"))

        // Then
        await fulfillment(of: [selected], timeout: 1)
        let store = try selectedStore.unwrapped()
        XCTAssertEqual(store.storeId, 116)
        XCTAssertEqual(store.latitude, 37.4983268205018, accuracy: 0.000001)
        XCTAssertEqual(store.longitude, 127.0256096087437, accuracy: 0.000001)
        XCTAssertEqual(storeRepository.fetchStoreInputs.map(\.storeId), ["116"])
        XCTAssertNil(routedLink)
        let log = try logManager.sentEvents.first.unwrapped()
        XCTAssertEqual(log.parameters["object_type"] as? String, "card")
        XCTAssertEqual(log.parameters["object_id"] as? String, "store")
        XCTAssertEqual(log.parameters["store_id"] as? String, "116")
        XCTAssertEqual(log.parameters["store_type"] as? String, "USER_STORE")
    }

    func test_TH1402_TC6_가게위치조회에실패하면_가게상세링크로이동한다() async throws {
        // Given
        let repository = MockScreenRepository()
        repository.fetchHomeCurationSectionResult = .success(try makeSection())
        let storeRepository = MockStoreRepository()
        let viewModel = makeViewModel(repository: repository, storeRepository: storeRepository)
        let loaded = expectItems(viewModel, count: 1)
        viewModel.input.setTabId.send("CURATION")
        viewModel.input.setLocation.send(location)
        await fulfillment(of: [loaded.expectation], timeout: 1)
        let routed = expectation(description: "deepLink")
        var routedLink: SDLink?
        viewModel.output.route
            .sink { route in
                if case .deepLink(let link) = route {
                    routedLink = link
                    routed.fulfill()
                }
            }
            .store(in: &cancellables)
        var didSelect = false
        viewModel.output.didSelectStore
            .sink { _ in didSelect = true }
            .store(in: &cancellables)

        // When
        viewModel.input.didTapCarouselCard.send((carouselId: "POPULAR_SNACKS", cardId: "S:116"))

        // Then
        await fulfillment(of: [routed], timeout: 1)
        XCTAssertEqual(routedLink?.link, "/store?storeId=116&storeType=USER_STORE")
        XCTAssertFalse(didSelect)
    }

    // MARK: TH-1402 TC7

    func test_TH1402_TC7_캐러셀광고카드는_여러번보여도_노출로그를한번만보내고_클릭로그를보낸다() async throws {
        // Given
        let logManager = MockLogManager()
        let section = try makeSection()
        let repository = MockScreenRepository()
        repository.fetchHomeCurationSectionResult = .success(section)
        let viewModel = makeViewModel(repository: repository, logManager: logManager)
        let loaded = expectItems(viewModel, count: 1)
        viewModel.input.setTabId.send("CURATION")
        viewModel.input.setLocation.send(location)
        await fulfillment(of: [loaded.expectation], timeout: 1)
        let admobCardId = try Self.firstCarouselAdmobCardId(section).unwrapped()

        // When
        viewModel.input.willDisplayCarouselCard.send((carouselId: "POPULAR_SNACKS", cardId: admobCardId))
        viewModel.input.willDisplayCarouselCard.send((carouselId: "POPULAR_SNACKS", cardId: admobCardId))
        viewModel.input.didTapCarouselCard.send((carouselId: "POPULAR_SNACKS", cardId: admobCardId))

        // Then
        XCTAssertEqual(logManager.sentEvents.map(\.name.rawValue), [EventName.impression.rawValue, EventName.click.rawValue])
        XCTAssertEqual(logManager.sentEvents.map { $0.parameters["object_id"] as? String }, ["admob", "admob"])
    }

    func test_TH1402_TC7_캐러셀사이광고는_여러번보여도_노출로그를한번만보내고_클릭로그를보낸다() async throws {
        // Given
        let logManager = MockLogManager()
        let section = try makeSection()
        let repository = MockScreenRepository()
        repository.fetchHomeCurationSectionResult = .success(section)
        let viewModel = makeViewModel(repository: repository, logManager: logManager)
        let loaded = expectItems(viewModel, count: 1)
        viewModel.input.setTabId.send("CURATION")
        viewModel.input.setLocation.send(location)
        await fulfillment(of: [loaded.expectation], timeout: 1)
        let admobItemId = try Self.firstAdmobItemId(section).unwrapped()

        // When
        viewModel.input.willDisplayAdmobItem.send(admobItemId)
        viewModel.input.willDisplayAdmobItem.send(admobItemId)
        viewModel.input.didTapAdmobItem.send(admobItemId)

        // Then
        XCTAssertEqual(logManager.sentEvents.map(\.name.rawValue), [EventName.impression.rawValue, EventName.click.rawValue])
        XCTAssertEqual(logManager.sentEvents.first?.parameters["tabId"] as? String, "CURATION")
    }
}

extension HomeCurationViewModelTests {
    private func makeViewModel(
        repository: MockScreenRepository,
        storeRepository: MockStoreRepository = MockStoreRepository(),
        logManager: MockLogManager = MockLogManager()
    ) -> HomeCurationViewModel {
        HomeCurationViewModel(dependency: .init(
            screenRepository: repository,
            storeRepository: storeRepository,
            logManager: logManager
        ))
    }

    private func makeSection() throws -> HomeCurationSectionResponse {
        try FixtureLoader.decode(HomeCurationSectionResponse.self, from: "HomeCurationSection")
    }

    private func expectItems(_ viewModel: HomeCurationViewModel, count: Int) -> ItemsRecorder {
        let recorder = ItemsRecorder(expectation: expectation(description: "items"))
        recorder.expectation.expectedFulfillmentCount = count
        recorder.expectation.assertForOverFulfill = false
        viewModel.output.items
            .dropFirst()
            .sink { [recorder] items in
                recorder.values.append(items)
                recorder.expectation.fulfill()
            }
            .store(in: &cancellables)
        return recorder
    }

    private static func carousel(_ item: HomeCurationSectionItem) -> HomeCurationCarouselViewData? {
        guard case .carousel(let carousel) = item else { return nil }
        return carousel
    }

    private static func responseCarousel(_ item: HomeCurationItem) -> HomeCurationCarousel? {
        guard case .carousel(let carousel) = item else { return nil }
        return carousel
    }

    private static func firstCarouselAdmobCardId(_ section: HomeCurationSectionResponse) -> String? {
        guard case .carousel(let carousel) = section.items.first else { return nil }
        for case .admobCard(let admob) in carousel.cards {
            return admob.cardId
        }
        return nil
    }

    private static func firstAdmobItemId(_ section: HomeCurationSectionResponse) -> String? {
        for case .admobCard(let admob) in section.items {
            return admob.cardId
        }
        return nil
    }
}

private final class ItemsRecorder {
    let expectation: XCTestExpectation
    var values: [[HomeCurationSectionItem]] = []

    var last: [HomeCurationSectionItem]? {
        values.last
    }

    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }
}

private extension Optional {
    func unwrapped(file: StaticString = #filePath, line: UInt = #line) throws -> Wrapped {
        try XCTUnwrap(self, file: file, line: line)
    }
}
