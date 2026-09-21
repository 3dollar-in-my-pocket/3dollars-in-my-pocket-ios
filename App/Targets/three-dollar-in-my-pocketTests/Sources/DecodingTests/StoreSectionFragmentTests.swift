import XCTest

import Model
@testable import Store

final class StoreSectionFragmentTests: XCTestCase {
    func test_서버가내려주는섹션타입명fragment를_섹션타입으로해석한다() {
        XCTAssertEqual(StoreSectionFragment.candidates(for: "PREVIEW"), [.preview])
        XCTAssertEqual(StoreSectionFragment.candidates(for: "INFO"), [.infoV1, .infoV2])
        XCTAssertEqual(StoreSectionFragment.candidates(for: "IMAGE"), [.image])
        XCTAssertEqual(StoreSectionFragment.candidates(for: "REVIEW"), [.review])
        XCTAssertEqual(StoreSectionFragment.candidates(for: "VISIT"), [.visit])
    }

    func test_레거시fragment도_섹션타입으로해석한다() {
        XCTAssertEqual(StoreSectionFragment.candidates(for: "home"), [.preview])
        XCTAssertEqual(StoreSectionFragment.candidates(for: "info"), [.infoV1, .infoV2])
        XCTAssertEqual(StoreSectionFragment.candidates(for: "images"), [.image])
        XCTAssertEqual(StoreSectionFragment.candidates(for: "reviews"), [.review])
    }

    func test_알수없는fragment는_빈후보를돌려준다() {
        XCTAssertEqual(StoreSectionFragment.candidates(for: "menu"), [])
        XCTAssertEqual(StoreSectionFragment.candidates(for: "unknown"), [])
    }

    func test_sectionId가일치하는섹션을_타입보다우선해서찾는다() throws {
        // Given: 서버가 섹션마다 내려주는 sectionId 로 탭을 연결한다. (INFO_V1 섹션의 sectionId 는 "INFO")
        let sections = try FixtureLoader.decode(StoreScreenV2Response.self, from: "StoreScreenV2WithTabs").sections

        // When & Then
        XCTAssertEqual(sections[4].type, .infoV1)
        XCTAssertEqual(sections[4].sectionId, "INFO")
        XCTAssertEqual(StoreSectionFragment.sectionIndex(for: "INFO", in: sections), 4)
        XCTAssertEqual(StoreSectionFragment.sectionIndex(for: "info", in: sections), 4)
        XCTAssertEqual(StoreSectionFragment.candidates(for: "AD_MOB"), [.admob])
        XCTAssertEqual(StoreSectionFragment.sectionIndex(for: "CTA", in: sections), 5)
        XCTAssertEqual(StoreSectionFragment.sectionIndex(for: "VISIT", in: sections), 7)
    }

    func test_sectionId가없는응답은_섹션타입으로폴백한다() throws {
        // Given
        let json = """
        {
            "sections": [
                { "type": "TAB", "tabs": [] },
                { "type": "MARGIN", "height": 8 },
                { "type": "AD_MOB", "cards": [] }
            ],
            "viewLog": { "eventType": "PAGE_VIEW", "screenName": "store_detail", "extraParameters": {} }
        }
        """
        let sections = try JSONDecoder().decode(StoreScreenV2Response.self, from: Data(json.utf8)).sections

        // When & Then
        XCTAssertNil(sections[0].sectionId)
        XCTAssertEqual(StoreSectionFragment.sectionIndex(for: "TAB", in: sections), 0)
        XCTAssertEqual(StoreSectionFragment.sectionIndex(for: "AD_MOB", in: sections), 2)
        XCTAssertNil(StoreSectionFragment.sectionIndex(for: "REVIEW", in: sections))
    }

    func test_로드된섹션에서_fragment에대응하는섹션인덱스를찾는다() throws {
        // Given: dev 실응답 (PREVIEW, MARGIN, TAB, EDIT, INFO_V1, CTA, MARGIN, VISIT, MARGIN, IMAGE, MARGIN, REVIEW, MARGIN, AD_MOB)
        let sections = try FixtureLoader.decode(StoreScreenV2Response.self, from: "StoreScreenV2WithTabs").sections

        // When & Then
        XCTAssertEqual(StoreSectionFragment.sectionIndex(for: "PREVIEW", in: sections), 0)
        XCTAssertEqual(StoreSectionFragment.sectionIndex(for: "INFO", in: sections), 4)
        XCTAssertEqual(StoreSectionFragment.sectionIndex(for: "IMAGE", in: sections), 9)
        XCTAssertEqual(StoreSectionFragment.sectionIndex(for: "REVIEW", in: sections), 11)
        XCTAssertNil(StoreSectionFragment.sectionIndex(for: "COUPON", in: sections))
        XCTAssertEqual(StoreSectionFragment.sectionType(for: "info", in: sections), .infoV1)
    }

    func test_탭링크fragment가_모두로드된섹션에대응된다() throws {
        // Given
        let sections = try FixtureLoader.decode(StoreScreenV2Response.self, from: "StoreScreenV2WithTabs").sections
        let tabSection = try XCTUnwrap(sections.compactMap { $0 as? StoreTabSection }.first)

        // When
        let fragments = tabSection.tabs.compactMap { $0.button.link?.link }.compactMap { URL(string: $0)?.fragment }
        let targetIndexes = fragments.map { StoreSectionFragment.sectionIndex(for: $0, in: sections) }

        // Then
        XCTAssertEqual(fragments, ["PREVIEW", "INFO", "IMAGE", "REVIEW"])
        XCTAssertEqual(targetIndexes, [0, 4, 9, 11])
    }
}
