import XCTest

import Model
@testable import dollar_in_my_pocket

final class BottomNavigationTabTests: XCTestCase {
    private let webBaseURL = URL(string: "https://echo.dev.threedollars.co.kr")

    // MARK: TH-1649 TC1

    func test_TH1649_TC1_응답순서대로_라벨_아이콘_선택색이_적용된다() throws {
        // Given
        let response = try FixtureLoader.decode(BottomNavigationResponse.self, from: "BottomNavigation")

        // When
        let items = MainTabBarItem.items(from: response, webBaseURL: webBaseURL)

        // Then
        XCTAssertEqual(items.map(\.id), ["home", "store_create", "event", "community", "my"])
        XCTAssertEqual(items.map(\.title), ["홈", "가게 제보", "이벤트", "커뮤니티", "마이페이지"])
        XCTAssertEqual(items[0].iconUrl, "https://storage.threedollars.co.kr/app/home_solid.png")
        XCTAssertEqual(items[0].selectedTintColor, UIColor(hex: response.tabs[0].selectedTintColor))
    }

    func test_TH1649_TC1_응답이없으면_기본4탭이다() {
        // Given / When
        let items = MainTabBarItem.items(from: nil, webBaseURL: webBaseURL)

        // Then
        XCTAssertEqual(items, MainTabBarItem.all)
    }

    // MARK: TH-1649 TC2

    func test_TH1649_TC2_APP_DEFINED_id는_기존화면에_매핑된다() throws {
        // Given
        let response = BottomNavigationResponse(tabs: try [
            tab(id: "home", type: "APP_DEFINED"),
            tab(id: "store_create", type: "APP_DEFINED"),
            tab(id: "community", type: "APP_DEFINED"),
            tab(id: "my", type: "APP_DEFINED")
        ])

        // When
        let items = MainTabBarItem.items(from: response, webBaseURL: webBaseURL)

        // Then
        XCTAssertEqual(items.map(\.destination), [.native(.home), .native(.write), .native(.community), .native(.my)])
    }

    func test_TH1649_TC2_type없는_구응답도_id로_기존화면에_매핑된다() throws {
        // Given
        let response = try FixtureLoader.decode(BottomNavigationResponse.self, from: "BottomNavigation")

        // When
        let items = MainTabBarItem.items(from: response, webBaseURL: webBaseURL)

        // Then
        XCTAssertEqual(items.map(\.tag), [.home, .write, nil, .community, .my])
    }

    // MARK: TH-1649 TC3

    func test_TH1649_TC3_WEB링크탭은_웹뷰탭이된다() throws {
        // Given
        let response = try FixtureLoader.decode(BottomNavigationResponse.self, from: "BottomNavigation")

        // When
        let event = MainTabBarItem.items(from: response, webBaseURL: webBaseURL).first { $0.id == "event" }

        // Then
        XCTAssertEqual(event?.destination, .web(try XCTUnwrap(URL(string: "https://echo.dev.threedollars.co.kr/events/point"))))
    }

    func test_TH1649_TC3_DYNAMIC_WEB_상대경로는_환경별_웹도메인이_붙는다() throws {
        // Given
        let response = BottomNavigationResponse(tabs: try [
            tab(id: "home", type: "APP_DEFINED"),
            tab(id: "new_event", type: "DYNAMIC", link: ("WEB", "/events/point"))
        ])

        // When
        let items = MainTabBarItem.items(from: response, webBaseURL: URL(string: "https://web.threedollars.co.kr"))

        // Then
        XCTAssertEqual(items.last?.destination, .web(try XCTUnwrap(URL(string: "https://web.threedollars.co.kr/events/point"))))
    }

    func test_TH1649_TC3_웹도메인은_디버그는_개발_릴리즈는_운영이다() {
        // Given / When
        let host = WebTabURL.baseURL?.host

        // Then
        #if DEBUG
        XCTAssertEqual(host, "echo.dev.threedollars.co.kr")
        #else
        XCTAssertEqual(host, "web.threedollars.co.kr")
        #endif
    }

    // MARK: TH-1649 TC5

    func test_TH1649_TC5_모르는id_APP_SCHEME탭과_모르는type은_제외된다() throws {
        // Given
        let response = BottomNavigationResponse(tabs: try [
            tab(id: "home", type: "APP_DEFINED"),
            tab(id: "unknown_screen", type: "APP_DEFINED"),
            tab(id: "legacy_unknown", type: nil, link: ("APP_SCHEME", "/unknown")),
            tab(id: "future", type: "SOMETHING_NEW", link: ("WEB", "https://web.threedollars.co.kr/future"))
        ])

        // When
        let items = MainTabBarItem.items(from: response, webBaseURL: webBaseURL)

        // Then
        XCTAssertEqual(items.map(\.id), ["home"])
    }

    // MARK: TH-1649 TC8

    func test_TH1649_TC8_홈탭이없으면_기본탭으로_대체된다() throws {
        // Given
        let response = BottomNavigationResponse(tabs: try [
            tab(id: "community", type: "APP_DEFINED"),
            tab(id: "event", type: "DYNAMIC", link: ("WEB", "https://web.threedollars.co.kr/events/point"))
        ])

        // When
        let items = MainTabBarItem.items(from: response, webBaseURL: webBaseURL)

        // Then
        XCTAssertEqual(items, MainTabBarItem.all)
    }

    func test_TH1649_TC8_같은화면id는_첫번째만_최대5개까지만_쓴다() throws {
        // Given
        let response = BottomNavigationResponse(tabs: try [
            tab(id: "home", type: "APP_DEFINED"),
            tab(id: "home", type: "APP_DEFINED"),
            tab(id: "event1", type: "DYNAMIC", link: ("WEB", "https://web.threedollars.co.kr/1")),
            tab(id: "event2", type: "DYNAMIC", link: ("WEB", "https://web.threedollars.co.kr/2")),
            tab(id: "community", type: "APP_DEFINED"),
            tab(id: "my", type: "APP_DEFINED"),
            tab(id: "event3", type: "DYNAMIC", link: ("WEB", "https://web.threedollars.co.kr/3"))
        ])

        // When
        let items = MainTabBarItem.items(from: response, webBaseURL: webBaseURL)

        // Then
        XCTAssertEqual(items.map(\.id), ["home", "event1", "event2", "community", "my"])
    }

    func test_TH1649_TC8_첫탭이_제보나_딥링크탭이면_홈을_기본선택한다() throws {
        // Given
        let response = BottomNavigationResponse(tabs: try [
            tab(id: "store_create", type: "APP_DEFINED"),
            tab(id: "medal", type: "DYNAMIC", link: ("APP_SCHEME", "/medal")),
            tab(id: "home", type: "APP_DEFINED")
        ])
        let items = MainTabBarItem.items(from: response, webBaseURL: webBaseURL)

        // When
        let index = MainTabBarItem.initialIndex(of: items)

        // Then
        XCTAssertEqual(items[index].id, "home")
    }

    func test_TH1649_TC8_첫탭이_화면탭이면_첫탭을_기본선택한다() throws {
        // Given
        let response = BottomNavigationResponse(tabs: try [
            tab(id: "event", type: "DYNAMIC", link: ("WEB", "https://web.threedollars.co.kr/events/point")),
            tab(id: "home", type: "APP_DEFINED")
        ])
        let items = MainTabBarItem.items(from: response, webBaseURL: webBaseURL)

        // When
        let index = MainTabBarItem.initialIndex(of: items)

        // Then
        XCTAssertEqual(index, 0)
    }

    // MARK: TH-1649 TC10

    func test_TH1649_TC10_탭딥링크_경로는_tab이다() {
        // Given / When
        let path = DeeplinkPath(value: "tab")

        // Then
        XCTAssertEqual(path, .tab)
    }

    func test_TH1649_TC10_DYNAMIC_APP_SCHEME탭은_딥링크만_띄우는_탭이된다() throws {
        // Given
        let response = BottomNavigationResponse(tabs: try [
            tab(id: "home", type: "APP_DEFINED"),
            tab(id: "medal", type: "DYNAMIC", link: ("APP_SCHEME", "/medal"))
        ])

        // When
        let medal = MainTabBarItem.items(from: response, webBaseURL: webBaseURL).last

        // Then
        guard case .deeplink(let link) = medal?.destination else {
            return XCTFail("딥링크 탭이 아닙니다: \(String(describing: medal?.destination))")
        }
        XCTAssertEqual(link.type, .appScheme)
        XCTAssertEqual(link.link, "/medal")
        XCTAssertNil(medal?.tag)
    }

    private func tab(id: String, type: String?, link: (type: String, link: String)? = nil) throws -> BottomNavigationItem {
        var json: [String: Any] = [
            "id": id,
            "label": id,
            "icon": ["url": "https://storage.threedollars.co.kr/app/\(id).png", "style": ["width": 24, "height": 24]],
            "selectedTintColor": "#FF5C43",
            "clickLog": [
                "screenName": "bottom_navigation",
                "objectType": "bar",
                "objectId": "tab",
                "extraParameters": ["value": id]
            ]
        ]
        if let type {
            json["type"] = type
        }
        if let link {
            json["link"] = ["type": link.type, "link": link.link]
        }
        let data = try JSONSerialization.data(withJSONObject: json)
        return try JSONDecoder().decode(BottomNavigationItem.self, from: data)
    }
}
