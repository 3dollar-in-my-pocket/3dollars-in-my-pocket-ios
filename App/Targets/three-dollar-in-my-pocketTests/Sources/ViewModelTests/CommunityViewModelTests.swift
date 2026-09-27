import Combine
import CoreLocation
import XCTest

import Common
import Log
import Model
@testable import Community

final class CommunityViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: TH-1348 TC9

    func test_TH1348_TC9_소식버튼을탭하면_마지막위치로_피드Route가발행된다() {
        // Given
        let preference = Preference(name: "CommunityViewModelTests")
        preference.userCurrentLocation = CLLocation(latitude: 37.5, longitude: 127.0)
        let viewModel = makeViewModel(preference: preference)
        let expectation = expectation(description: "route")
        var receivedLatitude: Double?
        var receivedLongitude: Double?
        viewModel.output.route
            .sink {
                if case .feedList(let config) = $0 {
                    receivedLatitude = config.mapLatitude
                    receivedLongitude = config.mapLongitude
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        viewModel.input.didTapFeedButton.send(())

        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(receivedLatitude, 37.5)
        XCTAssertEqual(receivedLongitude, 127.0)
    }

    // MARK: TH-1348 TC12

    func test_TH1348_TC12_소식버튼을탭하면_community_button_feed_클릭로그가전송된다() {
        // Given
        let logManager = MockLogManager()
        let viewModel = makeViewModel(logManager: logManager)

        // When
        viewModel.input.didTapFeedButton.send(())

        // Then
        XCTAssertEqual(logManager.sentEvents.count, 1)
        let event = logManager.sentEvents[0]
        XCTAssertEqual(event.name.rawValue, EventName.click.rawValue)
        XCTAssertEqual(event.screen.rawValue, "community")
        XCTAssertEqual((event.parameters["object_type"] as? String), "button")
        XCTAssertEqual((event.parameters["object_id"] as? String), "feed")
    }

    // MARK: - Helpers

    private func makeViewModel(
        preference: Preference = Preference(name: "CommunityViewModelTests"),
        logManager: MockLogManager = MockLogManager()
    ) -> CommunityViewModel {
        CommunityViewModel(
            communityRepository: MockCommunityRepository(),
            preference: preference,
            logManager: logManager
        )
    }
}
