import XCTest

import Model

final class AdmobUnitIdTests: XCTestCase {
    func test_TH1564_TC1_홈주변가게애드몹카드에adUnitId가있으면_모델에담긴다() throws {
        // Given
        let response = try FixtureLoader.decode(HomeListSectionResponse.self, from: "HomeListSectionWithAdmobUnitId")

        // When
        let card = try XCTUnwrap(response.cards.compactMap { $0 as? HomeListAdmobCardResponse }.first)

        // Then
        XCTAssertEqual(card.adUnitId, "ca-app-pub-5385646520024289/9943824572")
    }

    func test_TH1564_TC1_요즘뜨는애드몹카드에adUnitId가있으면_모델에담긴다() throws {
        // Given
        let response = try FixtureLoader.decode(HomeCurationSectionResponse.self, from: "HomeCurationSectionWithAdmobUnitId")

        // When
        let card = try XCTUnwrap(response.items.compactMap { item -> HomeListAdmobCardResponse? in
            guard case .admobCard(let card) = item else { return nil }
            return card
        }.first)

        // Then
        XCTAssertEqual(card.adUnitId, "ca-app-pub-5385646520024289/8271862280")
    }

    func test_TH1564_TC1_가게상세애드몹섹션에adUnitId가있으면_모든카드에담긴다() throws {
        // Given
        let response = try FixtureLoader.decode(StoreScreenV2Response.self, from: "StoreScreenV2WithAdmobUnitId")

        // When
        let adUnitIds = response.sections
            .compactMap { $0 as? StoreAdmobSection }
            .compactMap { $0.cards.first?.adUnitId }

        // Then
        XCTAssertEqual(adUnitIds.count, 3)
        XCTAssertTrue(adUnitIds.allSatisfy { $0 == "ca-app-pub-5385646520024289/7518571901" })
    }

    func test_TH1564_TC2_adUnitId가없는예전응답이면_파싱에성공하고nil이다() throws {
        // Given
        let homeList = try FixtureLoader.decode(HomeListSectionResponse.self, from: "HomeListSectionWithAdmobCard")
        let storeScreen = try FixtureLoader.decode(StoreScreenV2Response.self, from: "StoreScreenV2WithTabs")

        // When
        let homeCard = try XCTUnwrap(homeList.cards.compactMap { $0 as? HomeListAdmobCardResponse }.first)
        let storeSection = try XCTUnwrap(storeScreen.sections.compactMap { $0 as? StoreAdmobSection }.first)

        // Then
        XCTAssertNil(homeCard.adUnitId)
        XCTAssertNil(storeSection.cards.first?.adUnitId)
    }
}
