import XCTest

import Model

final class StoreThreadPostSectionTests: XCTestCase {
    func test_TH1448_TC2_THREADS_POST응답을디코딩하면_섹션필드와카드가파싱된다() throws {
        // Given
        let json = StoreThreadPostFixture.screenJSON(sections: [StoreThreadPostFixture.threadPostSectionJSON])

        // When
        let response = try JSONDecoder().decode(StoreScreenV2Response.self, from: Data(json.utf8))

        // Then
        let section = try XCTUnwrap(response.sections.first as? StoreThreadPostSection)
        XCTAssertEqual(section.type, .threadPost)
        XCTAssertEqual(section.sectionId, "THREADS_POST")
        XCTAssertEqual(section.style?.backgroundColor, "#FFFFFF")
        XCTAssertEqual(section.header.title.text, "쓰레드 소식")
        XCTAssertEqual(section.cards.map(\.permalink), StoreThreadPostFixture.permalinks)
        XCTAssertEqual(section.cards.first?.clickLog?.objectId, "threads_post")
        XCTAssertEqual(section.impressionLog?.objectType, "carousel")
    }

    func test_TH1448_TC12_알수없는섹션타입이섞이면_해당섹션만무시되고나머지는디코딩된다() throws {
        // Given
        let unknownSectionJSON = """
        { "type": "SOMETHING_NEW", "sectionId": "NEW" }
        """
        let json = StoreThreadPostFixture.screenJSON(sections: [unknownSectionJSON, StoreThreadPostFixture.threadPostSectionJSON])

        // When
        let response = try JSONDecoder().decode(StoreScreenV2Response.self, from: Data(json.utf8))

        // Then
        XCTAssertEqual(response.sections.count, 1)
        XCTAssertTrue(response.sections.first is StoreThreadPostSection)
    }
}

enum StoreThreadPostFixture {
    static let permalinks = [
        "https://www.threads.com/@gyeol_jeong84/post/DOaaa",
        "https://www.threads.com/@other_user/post/DObbb"
    ]

    static var threadPostSectionJSON: String {
        let cards = permalinks.map { permalink in
            """
            {
              "permalink": "\(permalink)",
              "clickLog": { "screenName": "store_detail", "objectType": "card", "objectId": "threads_post", "extraParameters": { "store_id": "12806182" } }
            }
            """
        }.joined(separator: ",")
        return """
        {
          "type": "THREADS_POST",
          "sectionId": "THREADS_POST",
          "style": { "backgroundColor": "#FFFFFF" },
          "header": { "title": { "text": "쓰레드 소식", "isHtml": false, "fontColor": "#0F0F0F" } },
          "cards": [\(cards)],
          "impressionLog": { "screenName": "store_detail", "objectType": "carousel", "objectId": "threads_post", "extraParameters": { "store_id": "12806182" } }
        }
        """
    }

    static func screenJSON(sections: [String]) -> String {
        """
        {
          "viewLog": { "screenName": "store_detail", "extraParameters": {} },
          "sections": [\(sections.joined(separator: ","))]
        }
        """
    }
}
