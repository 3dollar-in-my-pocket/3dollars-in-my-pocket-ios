import Combine
import CoreLocation
import XCTest

import Model
@testable import Home

@MainActor
final class HomeTabScrollPositionTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    private let location = CLLocation(latitude: 37.497941, longitude: 127.027616)
    private let otherLocation = CLLocation(latitude: 37.566535, longitude: 126.977969)

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: TH-1633 TC4

    func test_TH1633_TC4_요즘뜨는섹션을새로불러오면_스크롤초기화가전송된다() async throws {
        // Given
        let repository = try makeRepository()
        let viewModel = HomeCurationViewModel(dependency: .init(screenRepository: repository))
        await loadSection(viewModel, searchArea: HomeSearchArea(location: location, maxDistance: 1000))
        let resetCount = countResetScroll(viewModel)
        let reloaded = expectItems(viewModel)

        // When
        viewModel.input.setSearchArea.send(HomeSearchArea(location: otherLocation, maxDistance: 1000))

        // Then
        XCTAssertEqual(resetCount(), 1)
        await fulfillment(of: [reloaded], timeout: 5)
        XCTAssertEqual(repository.fetchHomeCurationSectionCalls.count, 2)
        XCTAssertEqual(resetCount(), 1)
    }

    // MARK: TH-1633 TC5

    func test_TH1633_TC5_다른탭에갔다가돌아오면_다시조회하지않고스크롤도초기화하지않는다() async throws {
        // Given
        let repository = try makeRepository()
        let viewModel = HomeCurationViewModel(dependency: .init(screenRepository: repository))
        await loadSection(viewModel, searchArea: HomeSearchArea(location: location, maxDistance: 1000))
        let resetCount = countResetScroll(viewModel)

        // When
        viewModel.input.setTabId.send(nil)
        viewModel.input.setTabId.send("CURATION")

        // Then
        XCTAssertEqual(repository.fetchHomeCurationSectionCalls.count, 1)
        XCTAssertEqual(resetCount(), 0)
    }

    // MARK: TH-1633 TC6

    func test_TH1633_TC6_카테고리칩을바꾸면_스크롤초기화를보내지않는다() async throws {
        // Given
        let repository = try makeRepository()
        repository.fetchHomeCurationCarouselCardsResult = .success(
            try JSONDecoder().decode(HomeCurationCarouselCardsResponse.self, from: Data(#"{"cards":[]}"#.utf8))
        )
        let viewModel = HomeCurationViewModel(dependency: .init(screenRepository: repository))
        await loadSection(viewModel, searchArea: HomeSearchArea(location: location, maxDistance: 1000))
        let resetCount = countResetScroll(viewModel)
        let cardsLoaded = expectItems(viewModel, count: 2)

        // When
        viewModel.input.didTapCategory.send((carouselId: "POPULAR_SNACKS", categoryId: "FRUIT_SANDO"))

        // Then
        await fulfillment(of: [cardsLoaded], timeout: 5)
        XCTAssertEqual(repository.fetchHomeCurationCarouselCardsCalls.count, 1)
        XCTAssertEqual(resetCount(), 0)
    }

    // MARK: TH-1633 TC7

    func test_TH1633_TC7_다른탭에있는동안지역이바뀌면_돌아올때응답전에스크롤초기화를보낸다() async throws {
        // Given
        let repository = try makeRepository()
        let viewModel = HomeCurationViewModel(dependency: .init(screenRepository: repository))
        await loadSection(viewModel, searchArea: HomeSearchArea(location: location, maxDistance: 1000))
        viewModel.input.setTabId.send(nil)
        let resetCount = countResetScroll(viewModel)
        viewModel.input.setSearchArea.send(HomeSearchArea(location: otherLocation, maxDistance: 1000))
        XCTAssertEqual(resetCount(), 0)

        // When
        viewModel.input.setTabId.send("CURATION")

        // Then
        XCTAssertEqual(resetCount(), 1)
        XCTAssertEqual(repository.fetchHomeCurationSectionCalls.count, 1)
    }

    private func makeRepository() throws -> MockScreenRepository {
        let repository = MockScreenRepository()
        repository.fetchHomeCurationSectionResult = .success(
            try FixtureLoader.decode(HomeCurationSectionResponse.self, from: "HomeCurationSection")
        )
        return repository
    }

    private func loadSection(_ viewModel: HomeCurationViewModel, searchArea: HomeSearchArea) async {
        let loaded = expectItems(viewModel)
        viewModel.input.setTabId.send("CURATION")
        viewModel.input.setSearchArea.send(searchArea)
        await fulfillment(of: [loaded], timeout: 5)
    }

    private func expectItems(_ viewModel: HomeCurationViewModel, count: Int = 1) -> XCTestExpectation {
        let expectation = expectation(description: "items")
        expectation.expectedFulfillmentCount = count
        expectation.assertForOverFulfill = false
        viewModel.output.items
            .dropFirst()
            .sink { _ in expectation.fulfill() }
            .store(in: &cancellables)
        return expectation
    }

    private func countResetScroll(_ viewModel: HomeCurationViewModel) -> () -> Int {
        var count = 0
        viewModel.output.resetScroll
            .sink { _ in count += 1 }
            .store(in: &cancellables)
        return { count }
    }
}
