import XCTest

import Model

final class StorePreviewMoreSectionTests: XCTestCase {
    // MARK: TH-1583 TC4

    func test_TH1583_TC4_미리보기응답의PREVIEW_MORE는_제목을가진섹션으로파싱된다() throws {
        // When
        let response = try FixtureLoader.decode(StorePreviewScreenResponse.self, from: "StorePreviewWithAdmob")

        // Then
        let section = try XCTUnwrap(response.sections.last as? StorePreviewMoreSection)
        XCTAssertEqual(section.type, .previewMore)
        XCTAssertTrue(section.header.title.text.contains("가게 정보"))
    }
}
