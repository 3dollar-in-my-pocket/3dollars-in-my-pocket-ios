import XCTest

import Model

final class StoreCalloutSectionTests: XCTestCase {
    func test_CALLOUT섹션이_이미지와텍스트로내려와도_응답전체가디코딩된다() throws {
        // Given & When
        let response = try FixtureLoader.decode(StoreScreenV2Response.self, from: "StoreScreenV2WithCallout")

        // Then
        let callout = try XCTUnwrap(response.sections.compactMap { $0 as? StoreCalloutSection }.first)
        XCTAssertEqual(callout.sectionId, "CALLOUT")
        XCTAssertNotNil(callout.content.image)
        XCTAssertNotNil(callout.content.text)
        XCTAssertNil(callout.content.title)
    }

    func test_CALLOUT섹션이_title형태로내려와도_디코딩된다() throws {
        // Given
        let json = """
        {
            "type": "CALLOUT",
            "sectionId": "CALLOUT",
            "content": {
                "title": { "text": "제목", "isHtml": false, "fontColor": "#0F0F0F" }
            },
            "style": { "backgroundColor": "#FFFFFF" }
        }
        """

        // When
        let section = try JSONDecoder().decode(StoreCalloutSection.self, from: Data(json.utf8))

        // Then
        XCTAssertEqual(section.content.title?.text, "제목")
        XCTAssertNil(section.content.image)
        XCTAssertNil(section.content.text)
    }
}
