import Combine
import CoreLocation
import XCTest

import Common
import Model
@testable import Home

final class HomeDeepLinkLandingTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: TH-1536 TC1

    func test_TH1536_TC1_홈준비후외부링크로가게가들어오면_가게위치로카메라가이동하고_펼친시트Route가발행된다() throws {
        // Given
        let storeRepository = try makeStoreRepository()
        let viewModel = makeViewModel(storeRepository: storeRepository)
        viewModel.input.onInitialMapDistanceReady.send(1000)
        var cameraPositions: [(CLLocation, Double?)] = []
        viewModel.output.initialCameraPosition.sink { cameraPositions.append($0) }.store(in: &cancellables)
        let routed = expectation(description: "route")
        var landedStoreId: Int?
        var landedLocation: CLLocation?
        var landedIsExpanded: Bool?
        viewModel.output.route
            .sink {
                if case .presentLandingStorePreview(let storeId, let location, let isExpanded) = $0 {
                    landedStoreId = storeId
                    landedLocation = location
                    landedIsExpanded = isExpanded
                    routed.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        viewModel.input.landStoreFromDeepLink.send((storeId: 12806182, isExpanded: true))

        // Then
        wait(for: [routed], timeout: 2)
        XCTAssertEqual(landedStoreId, 12806182)
        XCTAssertEqual(landedIsExpanded, true)
        XCTAssertEqual(landedLocation?.coordinate.latitude ?? 0, Self.storeLatitude, accuracy: 0.000001)
        XCTAssertEqual(landedLocation?.coordinate.longitude ?? 0, Self.storeLongitude, accuracy: 0.000001)
        let camera = try XCTUnwrap(cameraPositions.last)
        XCTAssertEqual(camera.0.coordinate.latitude, Self.storeLatitude, accuracy: 0.000001)
        XCTAssertEqual(camera.0.coordinate.longitude, Self.storeLongitude, accuracy: 0.000001)
    }

    // MARK: TH-1536 TC2

    func test_TH1536_TC2_홈준비전에외부링크로가게가들어오면_최초카메라이동때까지보류했다가_가게위치로랜딩한다() throws {
        // Given
        let storeRepository = try makeStoreRepository()
        let viewModel = makeViewModel(storeRepository: storeRepository)
        var routes: [HomeViewModel.Route] = []
        viewModel.output.route.sink { routes.append($0) }.store(in: &cancellables)
        var cameraPositions: [(CLLocation, Double?)] = []
        viewModel.output.initialCameraPosition.sink { cameraPositions.append($0) }.store(in: &cancellables)
        let landed = expectation(description: "landing")
        viewModel.output.route
            .sink {
                if case .presentLandingStorePreview(12806182, _, true) = $0 { landed.fulfill() }
            }
            .store(in: &cancellables)
        viewModel.input.landStoreFromDeepLink.send((storeId: 12806182, isExpanded: true))
        let fetched = XCTNSPredicateExpectation(
            predicate: NSPredicate { _, _ in storeRepository.fetchStorePreviewCallCount > 0 },
            object: nil
        )
        wait(for: [fetched], timeout: 2)
        XCTAssertTrue(routes.isEmpty)
        XCTAssertTrue(cameraPositions.isEmpty)

        // When
        viewModel.input.onInitialMapDistanceReady.send(1000)

        // Then
        wait(for: [landed], timeout: 2)
        let camera = try XCTUnwrap(cameraPositions.last)
        XCTAssertEqual(camera.0.coordinate.latitude, Self.storeLatitude, accuracy: 0.000001)
        XCTAssertEqual(camera.0.coordinate.longitude, Self.storeLongitude, accuracy: 0.000001)
    }

    // MARK: TH-1536 TC3

    func test_TH1536_TC3_외부링크로접힘이요청되면_접힌시트Route가발행된다() throws {
        // Given
        let viewModel = makeViewModel(storeRepository: try makeStoreRepository())
        viewModel.input.onInitialMapDistanceReady.send(1000)
        let routed = expectation(description: "route")
        var isExpanded: Bool?
        viewModel.output.route
            .sink {
                if case .presentLandingStorePreview(_, _, let value) = $0 {
                    isExpanded = value
                    routed.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        viewModel.input.landStoreFromDeepLink.send((storeId: 12806182, isExpanded: false))

        // Then
        wait(for: [routed], timeout: 2)
        XCTAssertEqual(isExpanded, false)
    }

    // MARK: TH-1536 TC8

    func test_TH1536_TC8_홈조회범위밖가게로랜딩하면_가게위치기준으로주변가게를다시조회한다() throws {
        // Given
        let screenRepository = MockScreenRepository()
        let viewModel = makeViewModel(storeRepository: try makeStoreRepository(), screenRepository: screenRepository)
        viewModel.input.onInitialMapDistanceReady.send(1000)
        let routed = expectation(description: "route")
        viewModel.output.route
            .sink { if case .presentLandingStorePreview = $0 { routed.fulfill() } }
            .store(in: &cancellables)
        viewModel.input.landStoreFromDeepLink.send((storeId: 12806182, isExpanded: true))
        wait(for: [routed], timeout: 2)
        let fetched = expectation(description: "fetch")
        viewModel.output.showLoading
            .filter { $0 == false }
            .first()
            .sink { _ in fetched.fulfill() }
            .store(in: &cancellables)

        // When
        viewModel.input.onInitialMapDistanceReady.send(800)

        // Then
        wait(for: [fetched], timeout: 2)
        let input = try XCTUnwrap(screenRepository.fetchHomeSectionListInputs.last)
        XCTAssertEqual(input.mapLatitude, Self.storeLatitude, accuracy: 0.000001)
        XCTAssertEqual(input.mapLongitude, Self.storeLongitude, accuracy: 0.000001)
        XCTAssertEqual(input.distanceM, 800)
    }

    // MARK: TH-1536 TC13

    func test_TH1536_TC13_가게미리보기조회에실패하면_기존처럼가게상세로이동한다() {
        // Given
        let storeRepository = MockStoreRepository()
        let viewModel = makeViewModel(storeRepository: storeRepository)
        viewModel.input.onInitialMapDistanceReady.send(1000)
        let routed = expectation(description: "route")
        var detailStoreId: Int?
        viewModel.output.route
            .sink {
                if case .pushStoreDetail(let storeId) = $0 {
                    detailStoreId = storeId
                    routed.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        viewModel.input.landStoreFromDeepLink.send((storeId: 999, isExpanded: true))

        // Then
        wait(for: [routed], timeout: 2)
        XCTAssertEqual(detailStoreId, 999)
    }
}

private extension HomeDeepLinkLandingTests {
    static let storeLatitude = 37.5508634
    static let storeLongitude = 127.128835

    func makeStoreRepository() throws -> MockStoreRepository {
        let json = """
        {
          "sections": [
            {
              "type": "PREVIEW",
              "markers": [
                {
                  "focused": { "image": { "url": "https://example.com/focused.png", "style": { "width": 32.0, "height": 40.0 } }, "style": { "backgroundColor": "#FF5C43" } },
                  "unfocused": { "image": { "url": "https://example.com/unfocused.png", "style": { "width": 28.0, "height": 28.0 } }, "style": { "backgroundColor": "#FF5C43" } },
                  "location": { "latitude": \(Self.storeLatitude), "longitude": \(Self.storeLongitude) },
                  "clickLog": { "screenName": "home", "objectType": "marker", "objectId": "store", "extraParameters": { "store_id": "12806182" } }
                }
              ],
              "header": { "title": { "text": "가게", "isHtml": false, "fontColor": "#0F0F0F" } },
              "metadata": { "primary": [], "secondary": [], "separator": { "url": "https://example.com/dot.png", "style": { "width": 2.0, "height": 2.0 } } },
              "actionBars": [],
              "images": [],
              "bodies": []
            }
          ],
          "viewLog": { "screenName": "home_store_preview", "extraParameters": {} }
        }
        """
        let response = try JSONDecoder().decode(StorePreviewScreenResponse.self, from: Data(json.utf8))
        let repository = MockStoreRepository()
        repository.fetchStorePreviewResult = .success(response)
        return repository
    }

    func makeViewModel(
        storeRepository: MockStoreRepository,
        screenRepository: MockScreenRepository = MockScreenRepository()
    ) -> HomeViewModel {
        HomeViewModel(dependency: .init(
            screenRepository: screenRepository,
            storeRepository: storeRepository,
            advertisementRepository: MockAdvertisementRepository(),
            userRepository: MockUserRepository(),
            mapRepository: MockMapRepository(),
            locationManager: MockLocationManager(),
            preference: Preference(name: "HomeDeepLinkLandingTests"),
            logManager: MockLogManager()
        ))
    }
}
