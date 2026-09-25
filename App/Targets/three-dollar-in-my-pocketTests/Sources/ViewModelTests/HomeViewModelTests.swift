import Combine
import CoreLocation
import XCTest

import Common
import Log
import Model
import Networking
@testable import Home

final class HomeViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: TH-1348 TC7

    func test_TH1348_TC7_가게제보버튼을탭하면_지도위치로_가게제보Route가발행된다() {
        // Given
        let viewModel = makeViewModel()
        let location = CLLocation(latitude: 37.5, longitude: 127.0)
        viewModel.input.changeMapLocation.send(location)
        let expectation = expectation(description: "route")
        var receivedLocation: CLLocation?
        viewModel.output.route
            .sink {
                if case .presentWriteStore(_, let location) = $0 {
                    receivedLocation = location
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        viewModel.input.didTapWriteButton.send(())

        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(receivedLocation?.coordinate.latitude, 37.5)
        XCTAssertEqual(receivedLocation?.coordinate.longitude, 127.0)
    }

    // MARK: TH-1348 TC11

    func test_TH1348_TC11_가게제보버튼을탭하면_home_button_write_클릭로그가전송된다() {
        // Given
        let logManager = MockLogManager()
        let viewModel = makeViewModel(logManager: logManager)

        // When
        viewModel.input.didTapWriteButton.send(())

        // Then
        XCTAssertEqual(logManager.sentEvents.count, 1)
        let event = logManager.sentEvents[0]
        XCTAssertEqual(event.name.rawValue, EventName.click.rawValue)
        XCTAssertEqual(event.screen.rawValue, "home")
        XCTAssertEqual((event.parameters["object_type"] as? String), "button")
        XCTAssertEqual((event.parameters["object_id"] as? String), "write")
    }

    // MARK: - Helpers

    private func makeViewModel(logManager: MockLogManager = MockLogManager()) -> HomeViewModel {
        HomeViewModel(dependency: .init(
            screenRepository: MockScreenRepository(),
            advertisementRepository: MockAdvertisementRepository(),
            userRepository: MockUserRepository(),
            mapRepository: MockMapRepository(),
            locationManager: MockLocationManager(),
            preference: Preference(name: "HomeViewModelTests"),
            logManager: logManager
        ))
    }
}
