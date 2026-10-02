import XCTest

import Model
@testable import Home
@testable import Store

final class AdmobCardHeightTests: XCTestCase {
    func test_TH1430_TC1_홈리스트애드몹카드에height가있으면_광고슬롯이해당높이가된다() throws {
        // Given
        let response = try decodeHomeList(heights: [120])

        // When
        let card = try XCTUnwrap(response.cards.first as? HomeListAdmobCardResponse)

        // Then
        XCTAssertEqual(card.height, 120)
        XCTAssertEqual(HomeListAdmobCell.Layout.height(card), 120)
    }

    func test_TH1430_TC2_가게상세애드몹섹션카드에height가있으면_광고슬롯이해당높이가된다() throws {
        // Given
        let response = try FixtureLoader.decode(StoreScreenV2Response.self, from: "StoreScreenV2WithTabs")

        // When
        let section = try XCTUnwrap(response.sections.compactMap { $0 as? StoreAdmobSection }.first)

        // Then
        XCTAssertEqual(section.cards.first?.height, 100)
        XCTAssertEqual(StoreAdmobCell.Layout.height(section), 100)
    }

    func test_TH1430_TC3_높이가다른애드몹카드가여러개면_각카드가자기높이를가진다() throws {
        // Given
        let response = try decodeHomeList(heights: [50, 250])

        // When
        let heights = response.cards
            .compactMap { $0 as? HomeListAdmobCardResponse }
            .map { HomeListAdmobCell.Layout.height($0) }

        // Then
        XCTAssertEqual(heights, [50, 250])
    }

    func test_TH1430_TC4_height가50미만이면_광고슬롯이50으로표시된다() throws {
        // Given
        let response = try decodeHomeList(heights: [20])

        // When
        let card = try XCTUnwrap(response.cards.first as? HomeListAdmobCardResponse)

        // Then
        XCTAssertEqual(HomeListAdmobCell.Layout.height(card), 50)
    }

    private func decodeHomeList(heights: [Int]) throws -> HomeListSectionResponse {
        let cards = heights.enumerated().map { index, height in
            """
            {
                "type": "ADMOB_CARD",
                "cardId": "ADMOB:\(index)",
                "height": \(height),
                "clickLog": {
                    "eventType": "CLICK",
                    "screenName": "home",
                    "objectType": "card",
                    "objectId": "admob",
                    "extraParameters": {}
                },
                "impressionLog": {
                    "eventType": "IMPRESSION",
                    "screenName": "home",
                    "objectType": "card",
                    "objectId": "admob",
                    "extraParameters": {}
                }
            }
            """
        }
        let json = """
        {
            "cards": [\(cards.joined(separator: ","))],
            "cursor": { "nextCursor": null, "hasMore": false }
        }
        """
        return try JSONDecoder().decode(HomeListSectionResponse.self, from: XCTUnwrap(json.data(using: .utf8)))
    }
}
