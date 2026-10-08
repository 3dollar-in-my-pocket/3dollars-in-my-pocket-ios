import XCTest

import Model

final class HomeCurationResponseTests: XCTestCase {
    // MARK: TH-1402 TC1

    func test_TH1402_TC1_홈화면응답의_바텀시트탭섹션이_서버순서대로디코딩된다() throws {
        // Given & When
        let response = try FixtureLoader.decode(
            HomeFilterScreenResponse.self,
            from: "HomeFilterScreenWithBottomSheetTab"
        )

        // Then
        let section = try XCTUnwrap(response.sections.compactMap { $0 as? HomeBottomSheetTabSection }.first)
        XCTAssertEqual(section.tabs.map(\.tabId), ["CURATION", "DEFAULT"])
        XCTAssertEqual(section.tabs.map(\.viewType), [.curation, .storeList])
        XCTAssertEqual(section.tabs.map(\.defaultSelected), [true, false])
        XCTAssertEqual(section.tabs[0].clickLog.objectType, "bar")
        XCTAssertEqual(section.tabs[0].clickLog.objectId, "tab")
        XCTAssertNil(section.tabs[0].unselected.style.border)
        XCTAssertNotNil(section.tabs[0].selected.style.border)
    }

    // MARK: TH-1402 TC4

    func test_TH1402_TC4_큐레이션섹션응답의_아이템이_서버순서대로디코딩된다() throws {
        // Given & When
        let response = try FixtureLoader.decode(HomeCurationSectionResponse.self, from: "HomeCurationSection")

        // Then
        XCTAssertEqual(response.items.map(Self.itemKind), ["CAROUSEL", "ADMOB_CARD", "CAROUSEL"])
        guard case .carousel(let carousel) = response.items.first else { return XCTFail("첫 아이템이 캐러셀이 아님") }
        XCTAssertEqual(carousel.carouselId, "POPULAR_SNACKS")
        XCTAssertEqual(carousel.defaultCategoryId, "BUNGEOPPANG")
        XCTAssertEqual(carousel.categoryFilters.first?.categoryId, "BUNGEOPPANG")
        XCTAssertEqual(carousel.cards.count, 11)
        guard case .admobCard(let admob) = carousel.cards[3] else { return XCTFail("4번째 카드가 광고가 아님") }
        XCTAssertEqual(admob.height, 100)
    }

    func test_TH1402_TC4_가게카드는_이미지_제목_거리리뷰_별점칩과_링크가디코딩된다() throws {
        // Given & When
        let response = try FixtureLoader.decode(HomeCurationSectionResponse.self, from: "HomeCurationSection")

        // Then
        guard case .carousel(let carousel) = response.items.first,
              case .imagePreviewCard(let card) = carousel.cards.first else {
            return XCTFail("첫 캐러셀 첫 카드가 가게 카드가 아님")
        }
        XCTAssertEqual(card.cardId, "S:116")
        XCTAssertEqual(card.image.style.width, 100)
        XCTAssertEqual(card.metricLabel.count, 2)
        XCTAssertEqual(card.contextLabel.count, 1)
        XCTAssertEqual(card.link?.link, "/store?storeId=116&storeType=USER_STORE")
        XCTAssertEqual(card.clickLog?.objectId, "store")
    }

    func test_TH1402_TC4_칩선택카드응답이_디코딩된다() throws {
        // Given & When
        let response = try FixtureLoader.decode(HomeCurationCarouselCardsResponse.self, from: "HomeCurationCarouselCards")

        // Then
        XCTAssertEqual(response.cards.map(\.cardId), ["S:12805610", "S:12805286"])
    }

    // MARK: TH-1402 TC8

    func test_TH1402_TC8_모르는아이템과카드타입은_건너뛰고나머지는디코딩된다() throws {
        // Given
        let json = """
        {
            "items": [
                { "type": "UNKNOWN_SECTION", "foo": "bar" },
                {
                    "type": "CAROUSEL",
                    "carouselId": "POPULAR_SNACKS",
                    "header": { "title": { "text": "최근 인기 간식", "isHtml": false, "fontColor": "#0F0F0F" } },
                    "defaultCategoryId": "BUNGEOPPANG",
                    "categoryFilters": [],
                    "cards": [
                        { "type": "VIDEO_CARD", "cardId": "V:1" },
                        \(Self.previewCardJSON(cardId: "S:1"))
                    ]
                }
            ]
        }
        """

        // When
        let response = try JSONDecoder().decode(HomeCurationSectionResponse.self, from: Data(json.utf8))

        // Then
        XCTAssertEqual(response.items.count, 1)
        guard case .carousel(let carousel) = response.items.first else { return XCTFail("캐러셀이 디코딩되지 않음") }
        XCTAssertEqual(carousel.cards.map(\.cardId), ["S:1"])
    }

    func test_TH1402_TC8_칩선택응답의_모르는카드타입은_건너뛴다() throws {
        // Given
        let json = """
        { "cards": [ { "type": "VIDEO_CARD", "cardId": "V:1" }, \(Self.previewCardJSON(cardId: "S:2")) ] }
        """

        // When
        let response = try JSONDecoder().decode(HomeCurationCarouselCardsResponse.self, from: Data(json.utf8))

        // Then
        XCTAssertEqual(response.cards.map(\.cardId), ["S:2"])
    }

    func test_TH1402_TC8_가게카드에_refs가없어도_디코딩된다() throws {
        // Given
        let json = "{ \"cards\": [ \(Self.previewCardJSON(cardId: "S:3")) ] }"

        // When
        let response = try JSONDecoder().decode(HomeCurationCarouselCardsResponse.self, from: Data(json.utf8))

        // Then
        guard case .imagePreviewCard(let card) = response.cards.first else { return XCTFail("가게 카드가 아님") }
        XCTAssertEqual(card.refs, [])
    }

    // MARK: TH-1402 TC9

    func test_TH1402_TC9_캐러셀헤더의_부제목과우측액션이없으면_nil이다() throws {
        // Given & When
        let response = try FixtureLoader.decode(HomeCurationSectionResponse.self, from: "HomeCurationSection")

        // Then
        guard case .carousel(let carousel) = response.items.first else { return XCTFail("캐러셀이 아님") }
        XCTAssertNil(carousel.header.subTitle)
        XCTAssertNil(carousel.header.trailingAction)
    }
}

extension HomeCurationResponseTests {
    private static func itemKind(_ item: HomeCurationItem) -> String {
        switch item {
        case .carousel:
            return "CAROUSEL"
        case .admobCard:
            return "ADMOB_CARD"
        }
    }

    private static func previewCardJSON(cardId: String) -> String {
        """
        {
            "type": "IMAGE_PREVIEW_CARD",
            "cardId": "\(cardId)",
            "image": { "url": "https://example.com/a.png", "style": { "width": 100.0, "height": 100.0, "dimmed": false } },
            "title": { "text": "가게", "isHtml": false, "fontColor": "#0F0F0F" },
            "metricLabel": [],
            "contextLabel": [],
            "link": { "type": "APP_SCHEME", "link": "/store?storeId=1&storeType=USER_STORE" },
            "style": { "backgroundColor": "#FFFFFF" }
        }
        """
    }
}
