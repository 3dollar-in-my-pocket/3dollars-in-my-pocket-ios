import XCTest

import Log
import Model
@testable import dollar_in_my_pocket

final class MainTabBarViewModelTests: XCTestCase {

    // MARK: TC1

    func test_TC1_탭을누르면_클릭로그가_한건전송된다() {
        // Given
        let logManager = MockLogManager()
        let viewModel = makeViewModel(logManager: logManager)

        // When
        viewModel.input.didTapTab.send(.home)

        // Then
        XCTAssertEqual(logManager.sentEvents.count, 1)
        let event = logManager.sentEvents[0]
        XCTAssertEqual(event.name.rawValue, EventName.click.rawValue)
        XCTAssertEqual(event.screen.rawValue, "main_tab_bar")
    }

    // MARK: TC2

    func test_TC2_탭마다_고유한objectId가_전송된다() {
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
        [TabBarTag.home, .write, .community, .my].forEach { viewModel.input.didTapTab.send($0) }

        // Then
        XCTAssertEqual(logManager.sentEvents.count, 4)
        zip([TabBarTag.home, .write, .community, .my], logManager.sentEvents).forEach { tab, event in
            XCTAssertEqual(event.parameters["object_id"] as? String, expected[tab])
            XCTAssertEqual(event.parameters["object_type"] as? String, "tab")
            XCTAssertEqual(event.parameters["screen"] as? String, "main_tab_bar")
        }
    }

    // MARK: TC3

    func test_TC3_TabBarTag는_모두_서로다른_logObjectId를갖는다() {
        // Given / When
        let objectIds = [TabBarTag.home, .write, .community, .my].map { $0.logObjectId.rawValue }

        // Then
        XCTAssertEqual(objectIds, ["home", "write", "community", "my_page"])
        XCTAssertEqual(Set(objectIds).count, 4)
    }

    private func makeViewModel(logManager: MockLogManager) -> MainTabBarViewModel {
        MainTabBarViewModel(dependency: .init(logManager: logManager))
    }
}
