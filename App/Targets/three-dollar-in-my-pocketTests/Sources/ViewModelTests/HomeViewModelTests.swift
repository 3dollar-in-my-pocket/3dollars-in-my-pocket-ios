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

    // MARK: TH-1380 TC1

    func test_TH1380_TC1_주소검색으로위치를바꾸면_서버기본줌레벨로카메라가이동한다() throws {
        // Given
        let response = try FixtureLoader.decode(HomeFilterScreenResponse.self, from: "HomeFilterScreenWithMapControl")
        let screenRepository = MockScreenRepository(fetchHomeFilterScreenResult: .success(response))
        let viewModel = makeViewModel(screenRepository: screenRepository)
        let loaded = expectation(description: "filter")
        viewModel.output.filterDatasource
            .dropFirst()
            .first()
            .sink { _ in loaded.fulfill() }
            .store(in: &cancellables)
        viewModel.input.viewDidLoad.send(())
        wait(for: [loaded], timeout: 1)

        var cameraPositions: [(CLLocation, Double?)] = []
        var isHiddenResearchButton: Bool?
        viewModel.output.initialCameraPosition.sink { cameraPositions.append($0) }.store(in: &cancellables)
        viewModel.output.isHiddenResearchButton.sink { isHiddenResearchButton = $0 }.store(in: &cancellables)

        // When
        viewModel.input.searchByAddress.send(PlaceDocument(
            addressName: "서울 강남구",
            y: "37.4979",
            x: "127.0276",
            roadAddressName: "강남대로",
            placeName: "강남역"
        ))

        // Then
        let cameraPosition = try XCTUnwrap(cameraPositions.last)
        XCTAssertEqual(cameraPosition.0.coordinate.latitude, 37.4979, accuracy: 0.0001)
        XCTAssertEqual(cameraPosition.0.coordinate.longitude, 127.0276, accuracy: 0.0001)
        XCTAssertEqual(cameraPosition.1, response.configuration?.initialMapZoomLevel)
        XCTAssertEqual(isHiddenResearchButton, true)
    }

    // MARK: TH-1380 TC2

    func test_TH1380_TC2_주소검색후_바뀐줌에서잰반경으로가게를조회한다() {
        // Given
        let screenRepository = MockScreenRepository()
        let viewModel = makeViewModel(screenRepository: screenRepository)
        viewModel.input.searchByAddress.send(PlaceDocument(
            addressName: "서울 강남구",
            y: "37.4979",
            x: "127.0276",
            roadAddressName: "강남대로",
            placeName: "강남역"
        ))
        let fetched = expectation(description: "fetch")
        viewModel.output.showLoading
            .filter { $0 == false }
            .first()
            .sink { _ in fetched.fulfill() }
            .store(in: &cancellables)

        // When
        viewModel.input.onInitialMapDistanceReady.send(1234)

        // Then
        wait(for: [fetched], timeout: 1)
        XCTAssertEqual(screenRepository.fetchHomeSectionListInputs.last?.distanceM, 1234)
        XCTAssertEqual(screenRepository.fetchHomeSectionListInputs.last?.mapLatitude ?? 0, 37.4979, accuracy: 0.0001)
    }

    // MARK: - Helpers

    // MARK: TH-1402 TC6

    func test_TH1402_TC6_큐레이션가게가선택되면_지도를가게위치로옮기고_가게미리보기시트를띄운다() {
        // Given
        let viewModel = makeViewModel()
        var camera: CLLocation?
        viewModel.output.cameraPosition
            .sink { camera = $0.0 }
            .store(in: &cancellables)
        var preview: HomeCurationSelectedStore?
        viewModel.output.route
            .sink { route in
                if case let .presentStorePreview(storeId, latitude, longitude) = route {
                    preview = HomeCurationSelectedStore(storeId: storeId, latitude: latitude, longitude: longitude)
                }
            }
            .store(in: &cancellables)

        // When
        viewModel.input.bottomSheetDidSelectCurationStore.send(
            HomeCurationSelectedStore(storeId: 116, latitude: 37.4983, longitude: 127.0256)
        )

        // Then
        XCTAssertEqual(camera?.coordinate.latitude, 37.4983)
        XCTAssertEqual(camera?.coordinate.longitude, 127.0256)
        XCTAssertEqual(preview, HomeCurationSelectedStore(storeId: 116, latitude: 37.4983, longitude: 127.0256))
    }

    private func makeViewModel(
        logManager: MockLogManager = MockLogManager(),
        screenRepository: MockScreenRepository = MockScreenRepository()
    ) -> HomeViewModel {
        HomeViewModel(dependency: .init(
            screenRepository: screenRepository,
            advertisementRepository: MockAdvertisementRepository(),
            userRepository: MockUserRepository(),
            mapRepository: MockMapRepository(),
            locationManager: MockLocationManager(),
            preference: Preference(name: "HomeViewModelTests"),
            logManager: logManager
        ))
    }
}
