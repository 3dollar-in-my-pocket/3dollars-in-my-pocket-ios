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
        let firstReset = expectResetScroll(viewModel)
        viewModel.input.setTabId.send("CURATION")
        viewModel.input.setSearchArea.send(HomeSearchArea(location: location, maxDistance: 1000))
        await fulfillment(of: [firstReset], timeout: 5)
        let reset = expectResetScroll(viewModel)

        // When
        viewModel.input.setSearchArea.send(HomeSearchArea(location: otherLocation, maxDistance: 1000))

        // Then
        await fulfillment(of: [reset], timeout: 5)
        XCTAssertEqual(repository.fetchHomeCurationSectionCalls.count, 2)
    }

    // MARK: TH-1633 TC5

    func test_TH1633_TC5_다른탭에갔다가돌아오면_다시조회하지않고스크롤도초기화하지않는다() async throws {
        // Given
        let repository = try makeRepository()
        let viewModel = HomeCurationViewModel(dependency: .init(screenRepository: repository))
        let loaded = expectResetScroll(viewModel)
        viewModel.input.setTabId.send("CURATION")
        viewModel.input.setSearchArea.send(HomeSearchArea(location: location, maxDistance: 1000))
        await fulfillment(of: [loaded], timeout: 5)
        var resetCount = 0
        viewModel.output.resetScroll
            .sink { _ in resetCount += 1 }
            .store(in: &cancellables)

        // When
        viewModel.input.setTabId.send(nil)
        viewModel.input.setTabId.send("CURATION")
        try await Task.sleep(nanoseconds: 300_000_000)

        // Then
        XCTAssertEqual(repository.fetchHomeCurationSectionCalls.count, 1)
        XCTAssertEqual(resetCount, 0)
    }

    // MARK: TH-1633 TC6

    func test_TH1633_TC6_카테고리칩을바꾸면_스크롤초기화를보내지않는다() async throws {
        // Given
        let repository = try makeRepository()
        repository.fetchHomeCurationCarouselCardsResult = .success(
            try JSONDecoder().decode(HomeCurationCarouselCardsResponse.self, from: Data(#"{"cards":[]}"#.utf8))
        )
        let viewModel = HomeCurationViewModel(dependency: .init(screenRepository: repository))
        let loaded = expectResetScroll(viewModel)
        viewModel.input.setTabId.send("CURATION")
        viewModel.input.setSearchArea.send(HomeSearchArea(location: location, maxDistance: 1000))
        await fulfillment(of: [loaded], timeout: 5)
        var resetCount = 0
        viewModel.output.resetScroll
            .sink { _ in resetCount += 1 }
            .store(in: &cancellables)
        let cardsLoaded = expectation(description: "cards")
        cardsLoaded.assertForOverFulfill = false
        viewModel.output.items
            .dropFirst()
            .sink { _ in cardsLoaded.fulfill() }
            .store(in: &cancellables)

        // When
        viewModel.input.didTapCategory.send((carouselId: "POPULAR_SNACKS", categoryId: "FRUIT_SANDO"))

        // Then
        await fulfillment(of: [cardsLoaded], timeout: 5)
        XCTAssertEqual(resetCount, 0)
    }

    private func makeRepository() throws -> MockScreenRepository {
        let repository = MockScreenRepository()
        repository.fetchHomeCurationSectionResult = .success(
            try FixtureLoader.decode(HomeCurationSectionResponse.self, from: "HomeCurationSection")
        )
        return repository
    }

    private func expectResetScroll(_ viewModel: HomeCurationViewModel) -> XCTestExpectation {
        let expectation = expectation(description: "resetScroll")
        expectation.assertForOverFulfill = false
        viewModel.output.resetScroll
            .first()
            .sink { _ in expectation.fulfill() }
            .store(in: &cancellables)
        return expectation
    }
}
