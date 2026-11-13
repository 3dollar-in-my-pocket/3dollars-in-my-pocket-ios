import Combine
import CoreLocation
import XCTest

import Model
@testable import Home

@MainActor
final class HomeCurationMaxDistanceTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    private let location = CLLocation(latitude: 37.497941, longitude: 127.027616)

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: TH-1593 TC1

    func test_TH1593_TC1_큐레이션섹션을조회하면_지도반경이maxDistanceM으로담긴다() async throws {
        // Given
        let repository = try makeRepository()
        let viewModel = HomeCurationViewModel(dependency: .init(screenRepository: repository))
        let loaded = expectItems(viewModel)

        // When
        viewModel.input.setTabId.send("CURATION")
        viewModel.input.setSearchArea.send(HomeSearchArea(location: location, maxDistance: 4200))

        // Then
        await fulfillment(of: [loaded], timeout: 5)
        XCTAssertEqual(repository.fetchHomeCurationSectionCalls.map(\.input.maxDistanceM), [4200])
        XCTAssertEqual(repository.fetchHomeCurationSectionCalls.first?.input.mapLatitude, location.coordinate.latitude)
    }

    // MARK: TH-1593 TC2

    func test_TH1593_TC2_카테고리칩을바꾸면_카드요청에도같은반경이담긴다() async throws {
        // Given
        let repository = try makeRepository()
        repository.fetchHomeCurationCarouselCardsResult = .success(
            try JSONDecoder().decode(HomeCurationCarouselCardsResponse.self, from: Data(#"{"cards":[]}"#.utf8))
        )
        let viewModel = HomeCurationViewModel(dependency: .init(screenRepository: repository))
        let loaded = expectItems(viewModel)
        viewModel.input.setTabId.send("CURATION")
        viewModel.input.setSearchArea.send(HomeSearchArea(location: location, maxDistance: 4200))
        await fulfillment(of: [loaded], timeout: 5)
        let cardsLoaded = expectItems(viewModel, count: 2)

        // When
        viewModel.input.didTapCategory.send((carouselId: "POPULAR_SNACKS", categoryId: "FRUIT_SANDO"))

        // Then
        await fulfillment(of: [cardsLoaded], timeout: 5)
        XCTAssertEqual(repository.fetchHomeCurationCarouselCardsCalls.map(\.input.categoryId), ["FRUIT_SANDO"])
        XCTAssertEqual(repository.fetchHomeCurationCarouselCardsCalls.map(\.input.maxDistanceM), [4200])
    }

    // MARK: TH-1593 TC3

    func test_TH1593_TC3_같은위치에서반경만커져도_새반경으로다시조회한다() async throws {
        // Given
        let repository = try makeRepository()
        let viewModel = HomeCurationViewModel(dependency: .init(screenRepository: repository))
        let firstLoaded = expectItems(viewModel)
        viewModel.input.setTabId.send("CURATION")
        viewModel.input.setSearchArea.send(HomeSearchArea(location: location, maxDistance: 1000))
        await fulfillment(of: [firstLoaded], timeout: 5)
        let reloaded = expectItems(viewModel)

        // When
        viewModel.input.setSearchArea.send(HomeSearchArea(location: location, maxDistance: 9000))

        // Then
        await fulfillment(of: [reloaded], timeout: 5)
        XCTAssertEqual(repository.fetchHomeCurationSectionCalls.map(\.input.maxDistanceM), [1000, 9000])
    }

    private func makeRepository() throws -> MockScreenRepository {
        let repository = MockScreenRepository()
        repository.fetchHomeCurationSectionResult = .success(
            try FixtureLoader.decode(HomeCurationSectionResponse.self, from: "HomeCurationSection")
        )
        return repository
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
}
