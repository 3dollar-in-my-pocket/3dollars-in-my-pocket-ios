import Combine
import XCTest

import Common
import Log
import Model
@testable import Home
@testable import Store

final class SDUILogTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: TH-1434 TC1

    func test_TH1434_TC1_프리셋을적용하면_홈page_view에실을preset이갱신된다() {
        // Given
        let viewModel = makeHomeViewModel(fixture: "HomeListSectionWithFocusBounds")

        // When
        viewModel.input.applyPreset.send("event")

        // Then
        XCTAssertEqual(viewModel.output.preset.value, "event")
    }

    // MARK: TH-1434 TC4

    func test_TH1434_TC4_홈리스트가게카드를탭하면_storeId와storeType이담긴클릭로그가한건전송된다() throws {
        // Given
        let logManager = MockLogManager()
        let viewModel = makeHomeViewModel(fixture: "HomeListSectionWithFocusBounds", logManager: logManager)
        try loadCards(viewModel)
        let sentCount = logManager.sentEvents.count

        // When
        viewModel.input.bottomSheetDidTapCard.send(0)

        // Then
        let clicks = logManager.sentEvents.dropFirst(sentCount).filter { $0.name == .click }
        XCTAssertEqual(clicks.count, 1)
        XCTAssertEqual(clicks.first?.parameters["object_type"] as? String, "card")
        XCTAssertEqual(clicks.first?.parameters["object_id"] as? String, "store")
        XCTAssertEqual(clicks.first?.parameters["store_id"] as? String, "55")
        XCTAssertEqual(clicks.first?.parameters["store_type"] as? String, "USER_STORE")
    }

    // MARK: TH-1434 TC5

    func test_TH1434_TC5_지도마커를탭하면_storeId와storeType이담긴클릭로그가한건전송된다() throws {
        // Given
        let logManager = MockLogManager()
        let viewModel = makeHomeViewModel(fixture: "HomeListSectionWithFocusBounds", logManager: logManager)
        try loadCards(viewModel)
        let sentCount = logManager.sentEvents.count

        // When
        viewModel.input.onTapMarker.send(0)

        // Then
        let clicks = logManager.sentEvents.dropFirst(sentCount).filter { $0.name == .click }
        XCTAssertEqual(clicks.count, 1)
        XCTAssertEqual(clicks.first?.parameters["object_type"] as? String, "marker")
        XCTAssertEqual(clicks.first?.parameters["object_id"] as? String, "store")
        XCTAssertEqual(clicks.first?.parameters["store_id"] as? String, "55")
        XCTAssertEqual(clicks.first?.parameters["store_type"] as? String, "USER_STORE")
    }

    // MARK: TH-1434 TC12

    func test_TH1434_TC12_홈리스트애드몹광고가클릭되면_해당카드클릭로그가한건전송된다() throws {
        // Given
        let logManager = MockLogManager()
        let viewModel = makeHomeViewModel(fixture: "HomeListSectionWithAdmobCard", logManager: logManager)
        try loadCards(viewModel)
        let admobIndex = try XCTUnwrap(viewModel.output.bottomSheetCards.value.firstIndex { $0 is HomeListAdmobCardResponse })
        let sentCount = logManager.sentEvents.count

        // When
        viewModel.input.bottomSheetDidTapCard.send(admobIndex)

        // Then
        let clicks = logManager.sentEvents.dropFirst(sentCount).filter { $0.name == .click }
        XCTAssertEqual(clicks.count, 1)
        XCTAssertEqual(clicks.first?.parameters["object_type"] as? String, "card")
        XCTAssertEqual(clicks.first?.parameters["object_id"] as? String, "admob")
    }

    // MARK: TH-1434 TC16

    func test_TH1434_TC16_제보자화면수정버튼을탭하면_storeId가담긴클릭로그가전송된다() {
        // Given
        let logManager = MockLogManager()
        let viewModel = ContributorsViewModel(
            config: .init(storeId: 120009, onEditRequested: { }),
            dependency: .init(storeRepository: MockStoreRepository(), logManager: logManager)
        )

        // When
        viewModel.input.didTapEdit.send(())

        // Then
        XCTAssertEqual(logManager.sentEvents.count, 1)
        let event = logManager.sentEvents[0]
        XCTAssertEqual(event.screen.rawValue, "store_contributors")
        XCTAssertEqual(event.parameters["object_type"] as? String, "button")
        XCTAssertEqual(event.parameters["object_id"] as? String, "edit")
        XCTAssertEqual(event.parameters["store_id"] as? String, "120009")
    }

    // MARK: - Helpers

    private func makeHomeViewModel(fixture: String, logManager: MockLogManager = MockLogManager()) -> HomeViewModel {
        let response = try? FixtureLoader.decode(HomeListSectionResponse.self, from: fixture)
        let screenRepository = MockScreenRepository(fetchHomeSectionListResult: response.map { .success($0) })
        return HomeViewModel(dependency: .init(
            screenRepository: screenRepository,
            advertisementRepository: MockAdvertisementRepository(),
            userRepository: MockUserRepository(),
            mapRepository: MockMapRepository(),
            locationManager: MockLocationManager(),
            preference: Preference(name: "SDUILogTests"),
            logManager: logManager
        ))
    }

    private func loadCards(_ viewModel: HomeViewModel) throws {
        let expectation = expectation(description: "cards")
        viewModel.output.bottomSheetCards
            .dropFirst()
            .first { $0.isEmpty == false }
            .sink { _ in expectation.fulfill() }
            .store(in: &cancellables)

        viewModel.input.onTapResearch.send(())

        wait(for: [expectation], timeout: 2)
    }
}
