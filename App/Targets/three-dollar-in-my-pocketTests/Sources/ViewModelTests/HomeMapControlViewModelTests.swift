import Combine
import CoreLocation
import XCTest

import Common
import Log
import Model
@testable import Home

final class HomeMapControlViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: TH-1348 TC1

    func test_TH1348_TC1_섹션이내려오면_controls순서대로_버튼이노출된다() throws {
        // Given
        let section = try makeSection()
        let viewModel = makeViewModel()

        // When
        viewModel.input.setSection.send(section)

        // Then
        let filter = try XCTUnwrap(section.controls[0] as? HomeMapStoreFilterControl)
        let action = try XCTUnwrap(section.controls[1] as? HomeMapActionControl)
        XCTAssertEqual(viewModel.output.buttons.value, [
            .serverDriven(filter.options[0].button),
            .serverDriven(action.button)
        ])
    }

    // MARK: TH-1348 TC2

    func test_TH1348_TC2_현재위치버튼을탭하면_현재위치와_서버줌레벨로_이동한다() async throws {
        // Given
        let location = CLLocation(latitude: 37.5, longitude: 127.0)
        let locationManager = MockLocationManager(getCurrentLocationResult: .success(location))
        let viewModel = makeViewModel(locationManager: locationManager)
        viewModel.input.setSection.send(try makeSection())
        let expectation = expectation(description: "moveToCurrentLocation")
        var received: (location: CLLocation, zoomLevel: Double?)?
        viewModel.output.moveToCurrentLocation
            .sink { received = $0; expectation.fulfill() }
            .store(in: &cancellables)

        // When
        viewModel.input.didTapControl.send(1)

        // Then
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertEqual(received?.location.coordinate.latitude, 37.5)
        XCTAssertEqual(received?.location.coordinate.longitude, 127.0)
        XCTAssertEqual(received?.zoomLevel, 13.0)
    }

    // MARK: TH-1348 TC3

    func test_TH1348_TC3_필터가꺼진상태에서탭하면_켜짐버튼으로바뀌고_focusFavoriteStores가true가된다() throws {
        // Given
        let section = try makeSection()
        let filter = try XCTUnwrap(section.controls[0] as? HomeMapStoreFilterControl)
        let viewModel = makeViewModel()
        viewModel.input.setSection.send(section)
        var didChangeFilterCount = 0
        viewModel.output.didChangeFilter
            .sink { didChangeFilterCount += 1 }
            .store(in: &cancellables)

        // When
        viewModel.input.didTapControl.send(0)

        // Then
        XCTAssertEqual(viewModel.output.buttons.value[0], .serverDriven(filter.options[1].button))
        XCTAssertEqual(filter.options[1].button.image?.url, "https://storage.threedollars.co.kr/app/bookmark.png")
        XCTAssertEqual(viewModel.output.filterParams.value["focusFavoriteStores"], "true")
        XCTAssertEqual(didChangeFilterCount, 1)
    }

    // MARK: TH-1348 TC4

    func test_TH1348_TC4_필터가켜진상태에서다시탭하면_꺼짐버튼으로돌아가고_focusFavoriteStores가false가된다() throws {
        // Given
        let section = try makeSection()
        let filter = try XCTUnwrap(section.controls[0] as? HomeMapStoreFilterControl)
        let viewModel = makeViewModel()
        viewModel.input.setSection.send(section)
        viewModel.input.didTapControl.send(0)

        // When
        viewModel.input.didTapControl.send(0)

        // Then
        XCTAssertEqual(viewModel.output.buttons.value[0], .serverDriven(filter.options[0].button))
        XCTAssertEqual(filter.options[0].button.image?.url, "https://storage.threedollars.co.kr/app/bookmark_empty.png")
        XCTAssertEqual(viewModel.output.filterParams.value["focusFavoriteStores"], "false")
    }

    // MARK: TH-1348 TC5

    func test_TH1348_TC5_컨트롤을탭하면_서버clickLog값으로_클릭로그가전송된다() throws {
        // Given
        let logManager = MockLogManager()
        let viewModel = makeViewModel(logManager: logManager)
        viewModel.input.setSection.send(try makeSection())

        // When
        viewModel.input.didTapControl.send(0)
        viewModel.input.didTapControl.send(1)

        // Then
        XCTAssertEqual(logManager.sentEvents.count, 2)
        let filterLog = logManager.sentEvents[0]
        XCTAssertEqual(filterLog.name.rawValue, EventName.click.rawValue)
        XCTAssertEqual(filterLog.screen.rawValue, "home")
        XCTAssertEqual(filterLog.parameters["object_type"] as? String, "button")
        XCTAssertEqual(filterLog.parameters["object_id"] as? String, "map_favorite_store_filter")
        XCTAssertEqual(filterLog.parameters["value"] as? String, "false")
        let actionLog = logManager.sentEvents[1]
        XCTAssertEqual(actionLog.parameters["object_id"] as? String, "current_location")
    }

    // MARK: TH-1348 TC6

    func test_TH1348_TC6_섹션이없으면_현재위치버튼만폴백으로노출되고_필터파라미터가비어있다() {
        // Given
        let viewModel = makeViewModel()

        // When
        viewModel.input.setSection.send(nil)

        // Then
        XCTAssertEqual(viewModel.output.buttons.value, [.fallbackCurrentLocation])
        XCTAssertTrue(viewModel.output.filterParams.value.isEmpty)
    }

    func test_TH1348_TC6_폴백현재위치버튼을탭하면_줌레벨없이_현재위치로이동한다() async {
        // Given
        let location = CLLocation(latitude: 37.5, longitude: 127.0)
        let locationManager = MockLocationManager(getCurrentLocationResult: .success(location))
        let viewModel = makeViewModel(locationManager: locationManager)
        viewModel.input.setSection.send(nil)
        let expectation = expectation(description: "moveToCurrentLocation")
        var received: (location: CLLocation, zoomLevel: Double?)?
        viewModel.output.moveToCurrentLocation
            .sink { received = $0; expectation.fulfill() }
            .store(in: &cancellables)

        // When
        viewModel.input.didTapControl.send(0)

        // Then
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertEqual(received?.location.coordinate.latitude, 37.5)
        XCTAssertNil(received?.zoomLevel)
    }

    // MARK: TH-1348 TC13

    func test_TH1348_TC13_비로그인상태에서_필터를탭하면_로그인유도Route가발행되고_필터는바뀌지않는다() throws {
        // Given
        let preference = Preference(name: "HomeMapControlViewModelTests-anonymous")
        preference.isAnonymousUser = true
        let viewModel = makeViewModel(preference: preference)
        viewModel.input.setSection.send(try makeSection())
        let expectation = expectation(description: "route")
        viewModel.output.route
            .sink { if case .presentSigninDialog = $0 { expectation.fulfill() } }
            .store(in: &cancellables)

        // When
        viewModel.input.didTapControl.send(0)

        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(viewModel.output.filterParams.value["focusFavoriteStores"], "false")
    }

    // MARK: - Helpers

    private func makeSection() throws -> HomeMapControlSection {
        let response = try FixtureLoader.decode(HomeFilterScreenResponse.self, from: "HomeFilterScreenWithMapControl")
        return try XCTUnwrap(response.sections.compactMap { $0 as? HomeMapControlSection }.first)
    }

    private func makeViewModel(
        locationManager: MockLocationManager = MockLocationManager(),
        preference: Preference = Preference(name: "HomeMapControlViewModelTests"),
        logManager: MockLogManager = MockLogManager()
    ) -> HomeMapControlViewModel {
        HomeMapControlViewModel(dependency: .init(
            locationManager: locationManager,
            preference: preference,
            logManager: logManager
        ))
    }
}
