import XCTest

import Model
@testable import dollar_in_my_pocket

final class BottomNavigationResponseTests: XCTestCase {

    // MARK: TH-1649 TC1

    func test_TH1649_TC1_개발계응답을_순서대로_디코딩한다() throws {
        // Given / When
        let response = try FixtureLoader.decode(BottomNavigationResponse.self, from: "BottomNavigation")

        // Then
        XCTAssertEqual(response.tabs.map(\.id), ["home", "store_create", "event", "community", "my"])
        XCTAssertEqual(response.tabs[2].link?.type, .web)
        XCTAssertEqual(response.tabs[0].clickLog?.screenName, "bottom_navigation")
        XCTAssertEqual(response.viewLog?.screenName, "bottom_navigation")
    }

    func test_TH1649_TC1_type과_link없는_APP_DEFINED탭을_디코딩한다() throws {
        // Given
        let json = """
        {
          "id": "home",
          "label": "홈",
          "icon": { "url": "https://storage.threedollars.co.kr/app/home_solid.png", "style": { "width": 24, "height": 24 } },
          "selectedTintColor": "#FF5C43",
          "type": "APP_DEFINED",
          "clickLog": { "screenName": "bottom_navigation", "objectType": "bar", "objectId": "tab" }
        }
        """

        // When
        let item = try JSONDecoder().decode(BottomNavigationItem.self, from: Data(json.utf8))

        // Then
        XCTAssertEqual(item.type, .appDefined)
        XCTAssertNil(item.link)
    }

    // MARK: TH-1649 TC5

    func test_TH1649_TC5_모르는type은_unknown으로_디코딩한다() throws {
        // Given
        let json = """
        {
          "id": "future",
          "label": "미래",
          "icon": { "url": "https://storage.threedollars.co.kr/app/future.png", "style": { "width": 24, "height": 24 } },
          "selectedTintColor": "#FF5C43",
          "type": "SOMETHING_NEW"
        }
        """

        // When
        let item = try JSONDecoder().decode(BottomNavigationItem.self, from: Data(json.utf8))

        // Then
        XCTAssertEqual(item.type, .unknown)
    }
}
