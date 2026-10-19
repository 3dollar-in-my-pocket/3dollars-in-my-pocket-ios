import Combine
import XCTest

import Model
@testable import Home

final class StorePreviewMarkersTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func test_TH1484_TC1_미리보기응답에markers가있으면_지도에추가할마커로그대로전달된다() throws {
        // Given
        let viewModel = try makeViewModel(markersJSON: """
        [
          {
            "focused": { "image": { "url": "https://example.com/focused.png", "style": { "width": 32.0, "height": 40.0 } }, "style": { "backgroundColor": "#FF5C43" } },
            "unfocused": { "image": { "url": "https://example.com/unfocused.png", "style": { "width": 28.0, "height": 28.0 } }, "style": { "backgroundColor": "#FF5C43" } },
            "location": { "latitude": 37.566536, "longitude": 126.977966 },
            "clickLog": { "screenName": "home", "objectType": "marker", "objectId": "store", "extraParameters": { "store_id": "55" } }
          }
        ]
        """)
        let markersExpectation = expectation(description: "markers")
        var receivedMarkers: [HomeListCardMarker] = []
        viewModel.output.markers.sink { markers in
            receivedMarkers = markers
            markersExpectation.fulfill()
        }.store(in: &cancellables)

        // When
        viewModel.input.load.send(())

        // Then
        wait(for: [markersExpectation], timeout: 2)
        XCTAssertEqual(receivedMarkers.count, 1)
        XCTAssertEqual(receivedMarkers.first?.location.latitude, 37.566536)
        XCTAssertEqual(receivedMarkers.first?.location.longitude, 126.977966)
        XCTAssertEqual(receivedMarkers.first?.focused.image?.url, "https://example.com/focused.png")
    }

    func test_TH1484_TC2_미리보기응답에markers가없으면_추가할마커없이빈배열이전달된다() throws {
        // Given
        let viewModel = try makeViewModel(markersJSON: nil)
        let markersExpectation = expectation(description: "markers")
        var receivedMarkers: [HomeListCardMarker]?
        viewModel.output.markers.sink { markers in
            receivedMarkers = markers
            markersExpectation.fulfill()
        }.store(in: &cancellables)

        // When
        viewModel.input.load.send(())

        // Then
        wait(for: [markersExpectation], timeout: 2)
        XCTAssertEqual(receivedMarkers?.isEmpty, true)
    }

    private func makeViewModel(markersJSON: String?) throws -> StorePreviewBottomSheetViewModel {
        let markersField = markersJSON.map { "\"markers\": \($0)," } ?? ""
        let json = """
        {
          "sections": [
            {
              "type": "PREVIEW",
              \(markersField)
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
        return StorePreviewBottomSheetViewModel(
            config: .init(storeId: 55, latitude: 37.566536, longitude: 126.977966),
            dependency: .init(storeRepository: repository, logManager: MockLogManager())
        )
    }
}
