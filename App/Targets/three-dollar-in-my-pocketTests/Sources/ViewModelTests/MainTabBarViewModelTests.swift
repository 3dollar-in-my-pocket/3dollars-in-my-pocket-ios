import XCTest

import Log
import Model
@testable import dollar_in_my_pocket

final class MainTabBarViewModelTests: XCTestCase {

    // MARK: TH-1340 TC8

    func test_TH1340_TC8_탭을누르면_클릭로그가_한건전송된다() {
        // Given
        let logManager = MockLogManager()
        let viewModel = makeViewModel(logManager: logManager)

        // When
        viewModel.input.didTapTab.send(fallbackItem(.home))

        // Then
        XCTAssertEqual(logManager.sentEvents.count, 1)
        let event = logManager.sentEvents[0]
        XCTAssertEqual(event.name.rawValue, EventName.click.rawValue)
        XCTAssertEqual(event.screen.rawValue, "main_tab_bar")
    }

    // MARK: TH-1340 TC9

    func test_TH1340_TC9_탭마다_고유한objectId가_전송된다() {
        // Given
        let logManager = MockLogManager()
        let viewModel = makeViewModel(logManager: logManager)
        let expected: [TabBarTag: String] = [
            .home: "home",
            .write: "write",
            .community: "community",
            .my: "my_page"
        ]

        // When
        [TabBarTag.home, .write, .community, .my].forEach { viewModel.input.didTapTab.send(fallbackItem($0)) }

        // Then
        XCTAssertEqual(logManager.sentEvents.count, 4)
        zip([TabBarTag.home, .write, .community, .my], logManager.sentEvents).forEach { tab, event in
            XCTAssertEqual(event.parameters["object_id"] as? String, expected[tab])
            XCTAssertEqual(event.parameters["object_type"] as? String, "tab")
            XCTAssertEqual(event.parameters["screen"] as? String, "main_tab_bar")
        }
    }

    // MARK: TH-1340 TC10

    func test_TH1340_TC10_TabBarTag는_모두_서로다른_logObjectId를갖는다() {
        // Given / When
        let objectIds = [TabBarTag.home, .write, .community, .my].map { $0.logObjectId.rawValue }

        // Then
        XCTAssertEqual(objectIds, ["home", "write", "community", "my_page"])
        XCTAssertEqual(Set(objectIds).count, 4)
    }

    // MARK: TH-1649 TC6

    func test_TH1649_TC6_서버clickLog가있는_탭을누르면_서버로그와_기존탭로그가_한건씩전송된다() throws {
        // Given
        let logManager = MockLogManager()
        let viewModel = makeViewModel(logManager: logManager)
        let home = try XCTUnwrap(serverItems().first { $0.id == "home" })

        // When
        viewModel.input.didTapTab.send(home)

        // Then
        XCTAssertEqual(logManager.sentEvents.count, 2)
        XCTAssertEqual(logManager.sentEvents[0].screen.rawValue, "main_tab_bar")
        XCTAssertEqual(logManager.sentEvents[0].parameters["object_id"] as? String, "home")
        XCTAssertEqual(logManager.sentEvents[1].name.rawValue, EventName.click.rawValue)
        XCTAssertEqual(logManager.sentEvents[1].screen.rawValue, "bottom_navigation")
        XCTAssertEqual(logManager.sentEvents[1].parameters["object_type"] as? String, "bar")
        XCTAssertEqual(logManager.sentEvents[1].parameters["object_id"] as? String, "tab")
        XCTAssertEqual(logManager.sentEvents[1].parameters["value"] as? String, "home")
    }

    func test_TH1649_TC6_웹뷰탭을누르면_서버clickLog만_한건전송된다() throws {
        // Given
        let logManager = MockLogManager()
        let viewModel = makeViewModel(logManager: logManager)
        let event = try XCTUnwrap(serverItems().first { $0.id == "event" })

        // When
        viewModel.input.didTapTab.send(event)

        // Then
        XCTAssertEqual(logManager.sentEvents.count, 1)
        XCTAssertEqual(logManager.sentEvents[0].screen.rawValue, "bottom_navigation")
        XCTAssertEqual(logManager.sentEvents[0].parameters["value"] as? String, "event")
    }

    private func makeViewModel(logManager: MockLogManager) -> MainTabBarViewModel {
        MainTabBarViewModel(dependency: .init(logManager: logManager))
    }

    private func fallbackItem(_ tag: TabBarTag) -> MainTabBarItem {
        MainTabBarItem.all.first { $0.tag == tag }!
    }

    private func serverItems() throws -> [MainTabBarItem] {
        let response = try FixtureLoader.decode(BottomNavigationResponse.self, from: "BottomNavigation")
        return MainTabBarItem.items(from: response, webBaseURL: URL(string: "https://echo.dev.threedollars.co.kr"))
    }
}
