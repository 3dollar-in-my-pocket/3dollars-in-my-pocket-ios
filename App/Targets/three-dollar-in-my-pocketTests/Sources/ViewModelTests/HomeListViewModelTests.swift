import Combine
import XCTest

import Log
import Model
@testable import Home

final class HomeListViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    private func makeViewModel(logManager: MockLogManager = MockLogManager()) -> HomeListViewModel {
        return HomeListViewModel(dependency: .init(screenRepository: MockScreenRepository(), logManager: logManager))
    }

    private func makeTabSection() throws -> HomeBottomSheetTabSection {
        let response = try FixtureLoader.decode(HomeFilterScreenResponse.self, from: "HomeFilterScreenWithBottomSheetTab")
        return try XCTUnwrap(response.sections.compactMap { $0 as? HomeBottomSheetTabSection }.first)
    }

    // MARK: TH-1364 TC1, TH-1358 TC1 — 새 조회 결과로 교체되면 리스트 초기화

    func test_TH1364_TC1_카드목록이교체되면_리스트초기화를한번요청한다() {
        // Given
        let viewModel = makeViewModel()
        var resetCount = 0
        viewModel.output.resetList
            .sink { resetCount += 1 }
            .store(in: &cancellables)

        // When
        viewModel.input.updateCards.send([])
        viewModel.input.didReplaceCards.send(())

        // Then
        XCTAssertEqual(resetCount, 1)
    }

    func test_TH1364_TC2_페이지네이션으로카드가추가되기만하면_리스트초기화를요청하지않는다() {
        // Given
        let viewModel = makeViewModel()
        var resetCount = 0
        viewModel.output.resetList
            .sink { resetCount += 1 }
            .store(in: &cancellables)

        // When
        viewModel.input.updateCards.send([])
        viewModel.input.updateCards.send([])

        // Then
        XCTAssertEqual(resetCount, 0)
    }

    // MARK: TH-1402 TC1

    func test_TH1402_TC1_탭섹션이오면_서버순서대로노출하고_기본선택탭인큐레이션을보여준다() throws {
        // Given
        let logManager = MockLogManager()
        let viewModel = makeViewModel(logManager: logManager)

        // When
        viewModel.input.setTabSection.send(try makeTabSection())

        // Then
        let tabs = viewModel.output.tabs.value
        XCTAssertEqual(tabs.map(\.tab.tabId), ["CURATION", "DEFAULT"])
        XCTAssertEqual(tabs.map(\.isSelected), [true, false])
        XCTAssertEqual(viewModel.output.selectedViewType.value, .curation)
        XCTAssertTrue(logManager.sentEvents.isEmpty)
    }

    // MARK: TH-1402 TC2

    func test_TH1402_TC2_내주변간식탭을누르면_탭클릭로그후_가게리스트를보여준다() throws {
        // Given
        let logManager = MockLogManager()
        let viewModel = makeViewModel(logManager: logManager)
        viewModel.input.setTabSection.send(try makeTabSection())

        // When
        viewModel.input.didTapTab.send(1)

        // Then
        XCTAssertEqual(viewModel.output.selectedViewType.value, .storeList)
        XCTAssertEqual(viewModel.output.tabs.value.map(\.isSelected), [false, true])
        XCTAssertEqual(logManager.sentEvents.count, 1)
        let log = try XCTUnwrap(logManager.sentEvents.first)
        XCTAssertEqual(log.name.rawValue, EventName.click.rawValue)
        XCTAssertEqual(log.parameters["object_type"] as? String, "bar")
        XCTAssertEqual(log.parameters["object_id"] as? String, "tab")
        XCTAssertEqual(log.parameters["value"] as? String, "DEFAULT")
    }

    // MARK: TH-1402 TC3

    func test_TH1402_TC3_요즘뜨는간식탭을다시누르면_탭클릭로그후_큐레이션을보여준다() throws {
        // Given
        let logManager = MockLogManager()
        let viewModel = makeViewModel(logManager: logManager)
        viewModel.input.setTabSection.send(try makeTabSection())
        viewModel.input.didTapTab.send(1)

        // When
        viewModel.input.didTapTab.send(0)

        // Then
        XCTAssertEqual(viewModel.output.selectedViewType.value, .curation)
        XCTAssertEqual(logManager.sentEvents.count, 2)
        XCTAssertEqual(logManager.sentEvents.last?.parameters["value"] as? String, "CURATION")
    }
}
