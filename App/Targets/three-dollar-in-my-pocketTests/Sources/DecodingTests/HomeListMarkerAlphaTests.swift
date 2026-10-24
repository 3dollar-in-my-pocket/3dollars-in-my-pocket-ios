import XCTest

import Model

final class HomeListMarkerAlphaTests: XCTestCase {
    func test_TH1532_TC3_마커이미지alpha를디코딩하면_focused와unfocused값이각각보존된다() throws {
        // Given & When
        let response = try FixtureLoader.decode(
            HomeListSectionResponse.self,
            from: "HomeListSectionWithMarkerAlpha"
        )

        // Then
        let markers = response.cards
            .compactMap { $0 as? HomeListBasicCardResponse }
            .compactMap(\.marker)
        XCTAssertEqual(markers.count, 2)
        XCTAssertEqual(markers[0].focused.image?.style.alpha, 1.0)
        XCTAssertEqual(markers[0].unfocused.image?.style.alpha, 1.0)
        XCTAssertEqual(markers[1].focused.image?.style.alpha, 0.0)
        XCTAssertEqual(markers[1].unfocused.image?.style.alpha, 0.0)
    }
}
