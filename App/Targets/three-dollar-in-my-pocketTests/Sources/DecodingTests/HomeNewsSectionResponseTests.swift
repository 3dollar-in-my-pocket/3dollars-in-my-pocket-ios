import XCTest

import Model

final class HomeNewsSectionResponseTests: XCTestCase {
    // MARK: TH-1558 TC1

    func test_TH1558_TC1_개발계응답을디코딩하면_헤더와소식광고카드와커서와섹션노출로그가담긴다() throws {
        // Given / When
        let response = try FixtureLoader.decode(HomeNewsSectionResponse.self, from: "HomeNewsSection")

        // Then
        XCTAssertNotNil(response.header?.subTitle)
        XCTAssertEqual(response.items.map(\.cardId), [
            "ADMOB:145b038d-74f8-4cb6-b18e-1607d52ed712",
            "NEWS:6b03d032fdb9ab52247e1939",
            "NEWS:6af4a1f27af92de3599ff76b"
        ])
        XCTAssertTrue(response.cursor.hasMore)
        XCTAssertNotNil(response.cursor.nextCursor)
        XCTAssertEqual(response.impressionLog?.objectId, "home_news")

        guard case .contentCard(let review) = response.items[2] else { return XCTFail("리뷰 소식 카드가 아니다") }
        XCTAssertEqual(review.header.summary.metadata.count, 3)
        XCTAssertEqual(review.bodyBlocks.first?.heading?.trailingImages.count, 5)
        XCTAssertEqual(review.bodyBlocks.first?.images.map(\.style.width), [124, 124])
        XCTAssertNil(review.bodyBlocks.first?.textLeadingImage)
    }

    func test_TH1558_TC1_모르는카드타입과깨진카드는_건너뛰고나머지카드는보여준다() throws {
        // Given
        let json = """
        {
          "items": [
            { "type": "NEW_CARD_TYPE", "cardId": "UNKNOWN:1" },
            { "type": "CONTENT_CARD", "cardId": "NEWS:broken" },
            {
              "type": "ADMOB_CARD",
              "cardId": "ADMOB:1",
              "clickLog": { "screenName": "home", "objectType": "card", "objectId": "admob" },
              "impressionLog": { "screenName": "home", "objectType": "card", "objectId": "admob" },
              "height": 50
            }
          ],
          "cursor": { "nextCursor": null, "hasMore": false }
        }
        """

        // When
        let response = try JSONDecoder().decode(HomeNewsSectionResponse.self, from: Data(json.utf8))

        // Then
        XCTAssertEqual(response.items.map(\.cardId), ["ADMOB:1"])
        XCTAssertNil(response.header)
        XCTAssertFalse(response.cursor.hasMore)
    }
}
