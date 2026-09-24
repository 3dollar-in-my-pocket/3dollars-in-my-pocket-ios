import XCTest

import Model

final class HomeFilterScreenResponseTests: XCTestCase {
    func test_paramValue가불리언인라디오바가있어도_필터응답전체가디코딩된다() throws {
        // Given & When
        let response = try FixtureLoader.decode(
            HomeFilterScreenResponse.self,
            from: "HomeFilterScreenWithBoolParamValue"
        )

        // Then
        let bars = response.sections
            .compactMap { $0 as? HomeFilterSection }
            .flatMap(\.bars)
        XCTAssertEqual(bars.count, 5)
        XCTAssertEqual(bars.map(\.type), [.categoryBar, .radioBar, .radioBar, .actionBar, .radioBar])
        XCTAssertEqual(response.configuration?.initialMapZoomLevel, 14.5)
    }

    func test_paramValue는_문자열불리언null을모두문자열로정규화한다() throws {
        // Given & When
        let response = try FixtureLoader.decode(
            HomeFilterScreenResponse.self,
            from: "HomeFilterScreenWithBoolParamValue"
        )

        // Then
        let radioBars = response.sections
            .compactMap { $0 as? HomeFilterSection }
            .flatMap(\.bars)
            .compactMap { $0 as? HomeFilterRadioBar }
        let paramValues = Dictionary(
            uniqueKeysWithValues: radioBars.map { ($0.paramKey, $0.options.map(\.paramValue)) }
        )

        XCTAssertEqual(paramValues["focusLabels"], [nil, "LIVE_ALONE_YURI"])
        XCTAssertEqual(paramValues["focusFavoriteStores"], ["false", "true"])
        XCTAssertEqual(paramValues["sortType"], ["POPULAR"])
    }

    func test_paramValue가숫자로와도_문자열로디코딩된다() throws {
        // Given
        let json = """
        {
            "sections": [{
                "type": "HOME_FILTER",
                "bars": [{
                    "type": "RADIO_BAR",
                    "paramKey": "filterMinReviewRating",
                    "options": [
                        { "chip": { "text": { "text": "전체", "isHtml": false, "fontColor": "#5A5A5A" } } },
                        {
                            "chip": { "text": { "text": "4점 이상", "isHtml": false, "fontColor": "#5A5A5A" } },
                            "paramValue": 4
                        },
                        {
                            "chip": { "text": { "text": "4.5점 이상", "isHtml": false, "fontColor": "#5A5A5A" } },
                            "paramValue": 4.5
                        }
                    ]
                }]
            }]
        }
        """

        // When
        let response = try JSONDecoder().decode(HomeFilterScreenResponse.self, from: Data(json.utf8))

        // Then
        let radioBar = try XCTUnwrap(
            (response.sections.first as? HomeFilterSection)?.bars.first as? HomeFilterRadioBar
        )
        XCTAssertEqual(radioBar.options.map(\.paramValue), [nil, "4", "4.5"])
    }
}
