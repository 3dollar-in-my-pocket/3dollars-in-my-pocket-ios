import XCTest

import Model

final class HomeFilterScreenResponseTests: XCTestCase {
    // MARK: TH-1348 TC1

    func test_TH1348_TC1_HOME_MAP_CONTROL섹션이_controls순서대로_디코딩된다() throws {
        // Given & When
        let response = try FixtureLoader.decode(
            HomeFilterScreenResponse.self,
            from: "HomeFilterScreenWithMapControl"
        )

        // Then
        XCTAssertEqual(response.sections.map(\.type), [.homeFilter, .homeMapControl])
        let section = try XCTUnwrap(response.sections.compactMap { $0 as? HomeMapControlSection }.first)
        XCTAssertEqual(section.controls.map(\.type), [.filter, .action])

        let filter = try XCTUnwrap(section.controls[0] as? HomeMapStoreFilterControl)
        XCTAssertEqual(filter.paramKey, "focusFavoriteStores")
        XCTAssertEqual(filter.options.map(\.paramValue), [true, false])
        XCTAssertEqual(filter.options[0].button.image?.style.width, 28)
        XCTAssertEqual(filter.options[0].button.style.border?.color, "#E2E2E2")

        let action = try XCTUnwrap(section.controls[1] as? HomeMapActionControl)
        XCTAssertEqual(action.button.customAction?.actionType, .homeMapControlMoveToCurrentLocation)
        XCTAssertEqual(action.button.customAction?.extraParams["MAP_ZOOM_LEVEL"]?.doubleValue, 13.0)
        XCTAssertEqual(action.button.clickLog?.objectId, "current_location")
    }

    // MARK: TH-1348 TC6

    func test_TH1348_TC6_모르는컨트롤타입은_무시하고_나머지가디코딩된다() throws {
        // Given
        let json = """
        {
            "sections": [{
                "type": "HOME_MAP_CONTROL",
                "controls": [
                    { "type": "SOMETHING_NEW", "foo": 1 },
                    {
                        "type": "ACTION",
                        "button": {
                            "image": { "url": "https://x/location.png", "style": { "width": 28.0, "height": 28.0 } },
                            "style": { "backgroundColor": "#FFFFFF" }
                        }
                    }
                ]
            }]
        }
        """

        // When
        let response = try JSONDecoder().decode(HomeFilterScreenResponse.self, from: Data(json.utf8))

        // Then
        let section = try XCTUnwrap(response.sections.first as? HomeMapControlSection)
        XCTAssertEqual(section.controls.map(\.type), [.action])
    }

    func test_TH1348_TC6_HOME_MAP_CONTROL섹션이없는응답도_기존대로디코딩된다() throws {
        // Given & When
        let response = try FixtureLoader.decode(
            HomeFilterScreenResponse.self,
            from: "HomeFilterScreenWithBoolParamValue"
        )

        // Then
        XCTAssertTrue(response.sections.compactMap { $0 as? HomeMapControlSection }.isEmpty)
        XCTAssertEqual(response.sections.map(\.type), [.homeFilter])
    }

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
