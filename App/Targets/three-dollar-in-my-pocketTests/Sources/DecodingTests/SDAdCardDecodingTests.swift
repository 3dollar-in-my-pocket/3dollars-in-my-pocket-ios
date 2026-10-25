import XCTest

import Model
@testable import Home

final class SDAdCardDecodingTests: XCTestCase {
    func test_TH1528_TC1_홈리스트응답의AD_CARD를디코딩하면_필드가파싱되고_서버순서가유지된다() throws {
        // Given & When
        let response = try FixtureLoader.decode(HomeListSectionResponse.self, from: "HomeListSectionWithAdCard")

        // Then
        XCTAssertEqual(response.cards.map(\.type), [.basicCard, .basicCard, .adCard, .basicCard])
        let adCard = try XCTUnwrap(response.cards[2] as? SDAdCard)
        XCTAssertEqual(adCard.cardId, "AD:109")
        XCTAssertEqual(adCard.title?.text, "가3팀이 붕어빵을 판다?")
        XCTAssertEqual(adCard.subTitle?.text, "익선동 팝업에서 슈크림 붕어빵을 먼저 만나보세요")
        XCTAssertEqual(adCard.labels.first?.text?.text, "광고")
        XCTAssertNotNil(adCard.image)
        XCTAssertNil(adCard.trailingIcon)
        XCTAssertEqual(adCard.link?.type, .web)
        XCTAssertEqual(adCard.clickLog.objectId, "advertisement")
        XCTAssertEqual(adCard.impressionLog.objectId, "advertisement")
    }

    func test_TH1528_TC2_큐레이션캐러셀의AD_CARD를디코딩하면_가게카드사이서버순서위치에남는다() throws {
        // Given & When
        let response = try FixtureLoader.decode(HomeCurationSectionResponse.self, from: "HomeCurationSectionWithAdCard")

        // Then
        guard case .carousel(let carousel) = response.items.first else { return XCTFail("첫 아이템이 캐러셀이 아님") }
        XCTAssertEqual(carousel.cards.count, 4)
        guard case .adCard(let adCard) = carousel.cards[2] else { return XCTFail("3번째 카드가 광고가 아님") }
        XCTAssertEqual(adCard.cardId, "AD:110")
        XCTAssertEqual(carousel.cards[2].cardId, "AD:110")
    }

    func test_TH1528_TC3_상세v2응답의AD섹션을디코딩하면_필드가파싱되고_섹션순서가유지된다() throws {
        // Given & When
        let response = try FixtureLoader.decode(StoreScreenV2Response.self, from: "StoreScreenV2WithAdSection")

        // Then
        let adIndex = try XCTUnwrap(response.sections.firstIndex { $0.type == .advertisement })
        XCTAssertEqual(response.sections[adIndex - 1].type, .cta)
        let section = try XCTUnwrap(response.sections[adIndex] as? StoreAdSection)
        XCTAssertEqual(section.sectionId, "AD")
        XCTAssertEqual(section.style?.backgroundColor, "#FFFFFF")
        XCTAssertEqual(section.impressionLog?.objectId, "store_section")
        XCTAssertEqual(section.cards.first?.cardId, "AD:108")
        XCTAssertNotNil(section.cards.first?.trailingIcon)
    }

    func test_TH1528_TC12_상세에AD와AD_MOB이함께오면_서버순서대로둘다디코딩된다() throws {
        // Given & When
        let response = try FixtureLoader.decode(StoreScreenV2Response.self, from: "StoreScreenV2WithAdSection")

        // Then
        let types = response.sections.map(\.type)
        let adIndex = try XCTUnwrap(types.firstIndex(of: .advertisement))
        XCTAssertEqual(types[adIndex + 1], .admob)
        XCTAssertEqual(types.filter { $0 == .admob }.count, 3)
    }

    func test_TH1528_TC7_선택필드가없는광고카드도_디코딩되고_없는요소는nil이다() throws {
        // Given
        let json = """
        {
            "type": "AD_CARD",
            "cardId": "AD:1",
            "labels": [],
            "clickLog": { "screenName": "home", "objectType": "card", "objectId": "advertisement", "extraParameters": {}, "eventType": "CLICK" },
            "impressionLog": { "screenName": "home", "objectType": "card", "objectId": "advertisement", "extraParameters": {}, "eventType": "IMPRESSION" }
        }
        """

        // When
        let adCard = try JSONDecoder().decode(SDAdCard.self, from: Data(json.utf8))

        // Then
        XCTAssertNil(adCard.title)
        XCTAssertNil(adCard.subTitle)
        XCTAssertNil(adCard.image)
        XCTAssertNil(adCard.trailingIcon)
        XCTAssertNil(adCard.link)
        XCTAssertTrue(adCard.labels.isEmpty)
    }

    func test_TH1528_TC7_선택필드가없으면_리스트광고카드높이에서_해당영역이빠진다() throws {
        // Given
        let response = try FixtureLoader.decode(HomeListSectionResponse.self, from: "HomeListSectionWithAdCard")
        let adCard = try XCTUnwrap(response.cards[2] as? SDAdCard)
        let minimalJson = """
        {
            "type": "AD_CARD",
            "cardId": "AD:1",
            "labels": [],
            "clickLog": { "screenName": "home", "objectType": "card", "objectId": "advertisement", "extraParameters": {}, "eventType": "CLICK" },
            "impressionLog": { "screenName": "home", "objectType": "card", "objectId": "advertisement", "extraParameters": {}, "eventType": "IMPRESSION" }
        }
        """
        let minimalCard = try JSONDecoder().decode(SDAdCard.self, from: Data(minimalJson.utf8))

        // When
        let fullHeight = HomeListAdCell.Layout.height(adCard)
        let minimalHeight = HomeListAdCell.Layout.height(minimalCard)

        // Then
        XCTAssertEqual(fullHeight, 16 + 24 + 4 + 18 + 12 + 120 + 16)
        XCTAssertEqual(minimalHeight, 32)
    }

    func test_TH1528_TC13_알수없는카드타입이섞여도_광고카드를포함한나머지는디코딩된다() throws {
        // Given
        let json = """
        {
            "cards": [
                { "type": "FUTURE_CARD", "cardId": "F:1" },
                {
                    "type": "AD_CARD",
                    "cardId": "AD:1",
                    "labels": [],
                    "clickLog": { "screenName": "home", "objectType": "card", "objectId": "advertisement", "extraParameters": {}, "eventType": "CLICK" },
                    "impressionLog": { "screenName": "home", "objectType": "card", "objectId": "advertisement", "extraParameters": {}, "eventType": "IMPRESSION" }
                }
            ]
        }
        """

        // When
        let response = try JSONDecoder().decode(HomeListSectionResponse.self, from: Data(json.utf8))

        // Then
        XCTAssertEqual(response.cards.map(\.cardId), ["AD:1"])
    }
}
