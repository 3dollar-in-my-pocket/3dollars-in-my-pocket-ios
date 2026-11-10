import Combine
import XCTest

import Common
import Log
import Model
@testable import Home

final class HomeTabDeepLinkTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: TH-1578 TC1

    func test_TH1578_TC1_딥링크에tabId가있으면_홈API에tabId를그대로넘긴다() throws {
        // Given
        let screenRepository = MockScreenRepository(fetchHomeFilterScreenResult: .success(try makeResponse(defaultTabId: "NEWS")))
        let viewModel = makeHomeViewModel(screenRepository: screenRepository)
        let received = expectTabSection(viewModel)

        // When
        viewModel.input.applyDeepLink.send(.init(preset: nil, tabId: "NEWS"))

        // Then
        wait(for: [received], timeout: 1)
        XCTAssertEqual(screenRepository.fetchHomeFilterScreenInputs.map(\.tabId), ["NEWS"])
        XCTAssertNil(screenRepository.fetchHomeFilterScreenInputs.first?.preset)
    }

    func test_TH1578_TC1_tabId만있는딥링크는_필터와가게목록을건드리지않는다() throws {
        // Given
        let screenRepository = MockScreenRepository(fetchHomeFilterScreenResult: .success(try makeResponse(defaultTabId: "NEWS")))
        let viewModel = makeHomeViewModel(screenRepository: screenRepository)
        let received = expectTabSection(viewModel)
        var filterEmitCount = 0
        viewModel.output.filterDatasource
            .dropFirst()
            .sink { _ in filterEmitCount += 1 }
            .store(in: &cancellables)

        // When
        viewModel.input.applyDeepLink.send(.init(preset: nil, tabId: "NEWS"))

        // Then
        wait(for: [received], timeout: 1)
        XCTAssertNil(viewModel.output.preset.value)
        XCTAssertEqual(filterEmitCount, 0)
        XCTAssertTrue(screenRepository.fetchHomeSectionListInputs.isEmpty)
    }

    // MARK: TH-1578 TC2

    func test_TH1578_TC2_tabId딥링크응답이오면_탭선택초기화후_탭섹션을전달한다() throws {
        // Given
        let screenRepository = MockScreenRepository(fetchHomeFilterScreenResult: .success(try makeResponse(defaultTabId: "NEWS")))
        let viewModel = makeHomeViewModel(screenRepository: screenRepository)
        let received = expectTabSection(viewModel)
        var events: [String] = []
        viewModel.output.resetBottomSheetTabSelection
            .sink { events.append("reset") }
            .store(in: &cancellables)
        viewModel.output.bottomSheetTabSection
            .dropFirst()
            .sink { _ in events.append("section") }
            .store(in: &cancellables)

        // When
        viewModel.input.applyDeepLink.send(.init(preset: nil, tabId: "NEWS"))

        // Then
        wait(for: [received], timeout: 1)
        XCTAssertEqual(events, ["reset", "section"])
        let defaultTab = viewModel.output.bottomSheetTabSection.value?.tabs.first(where: \.defaultSelected)
        XCTAssertEqual(defaultTab?.tabId, "NEWS")
    }

    func test_TH1578_TC2_다른탭을보던중_선택초기화후탭섹션이오면_서버defaultSelected탭을선택한다() throws {
        // Given
        let logManager = MockLogManager()
        let viewModel = makeHomeListViewModel(logManager: logManager)
        viewModel.input.setTabSection.send(try makeTabSection(defaultTabId: "DEFAULT"))
        viewModel.input.didTapTab.send(1)
        XCTAssertEqual(viewModel.output.selectedViewType.value, .curation)

        // When
        viewModel.input.resetTabSelection.send(())
        viewModel.input.setTabSection.send(try makeTabSection(defaultTabId: "NEWS"))

        // Then
        XCTAssertEqual(viewModel.output.selectedViewType.value, .news)
        XCTAssertEqual(viewModel.output.tabs.value.map(\.isSelected), [false, false, true])
        XCTAssertEqual(logManager.sentEvents.filter { $0.name == .click }.count, 1)
    }

    // MARK: TH-1578 TC3

    func test_TH1578_TC3_preset과tabId가함께오면_홈API에둘다넘긴다() throws {
        // Given
        let screenRepository = MockScreenRepository(fetchHomeFilterScreenResult: .success(try makeResponse(defaultTabId: "CURATION")))
        let viewModel = makeHomeViewModel(screenRepository: screenRepository)
        let received = expectTabSection(viewModel)
        var resetCount = 0
        viewModel.output.resetBottomSheetTabSelection
            .sink { resetCount += 1 }
            .store(in: &cancellables)

        // When
        viewModel.input.applyDeepLink.send(.init(preset: "event", tabId: "CURATION"))

        // Then
        wait(for: [received], timeout: 1)
        let input = try XCTUnwrap(screenRepository.fetchHomeFilterScreenInputs.last)
        XCTAssertEqual(input.preset, "event")
        XCTAssertEqual(input.tabId, "CURATION")
        XCTAssertEqual(viewModel.output.preset.value, "event")
        XCTAssertEqual(resetCount, 1)
    }

    // MARK: TH-1578 TC4

    func test_TH1578_TC4_딥링크없이홈을열면_tabId없이조회하고_탭선택을초기화하지않는다() throws {
        // Given
        let screenRepository = MockScreenRepository(fetchHomeFilterScreenResult: .success(try makeResponse(defaultTabId: "DEFAULT")))
        let viewModel = makeHomeViewModel(screenRepository: screenRepository)
        let received = expectTabSection(viewModel)
        var resetCount = 0
        viewModel.output.resetBottomSheetTabSelection
            .sink { resetCount += 1 }
            .store(in: &cancellables)

        // When
        viewModel.input.viewDidLoad.send(())

        // Then
        wait(for: [received], timeout: 1)
        XCTAssertEqual(screenRepository.fetchHomeFilterScreenInputs.count, 1)
        XCTAssertNil(screenRepository.fetchHomeFilterScreenInputs.first?.tabId)
        XCTAssertEqual(resetCount, 0)
    }

    func test_TH1578_TC4_preset만있는딥링크는_tabId없이조회하고_탭선택을초기화하지않는다() throws {
        // Given
        let screenRepository = MockScreenRepository(fetchHomeFilterScreenResult: .success(try makeResponse(defaultTabId: "DEFAULT")))
        let viewModel = makeHomeViewModel(screenRepository: screenRepository)
        let received = expectTabSection(viewModel)
        var resetCount = 0
        viewModel.output.resetBottomSheetTabSelection
            .sink { resetCount += 1 }
            .store(in: &cancellables)

        // When
        viewModel.input.applyDeepLink.send(.init(preset: "event", tabId: nil))

        // Then
        wait(for: [received], timeout: 1)
        let input = try XCTUnwrap(screenRepository.fetchHomeFilterScreenInputs.last)
        XCTAssertEqual(input.preset, "event")
        XCTAssertNil(input.tabId)
        XCTAssertEqual(resetCount, 0)
    }

    func test_TH1578_TC4_선택초기화없이탭섹션이다시오면_사용자가고른탭을유지한다() throws {
        // Given
        let viewModel = makeHomeListViewModel()
        viewModel.input.setTabSection.send(try makeTabSection(defaultTabId: "DEFAULT"))
        viewModel.input.didTapTab.send(1)

        // When
        viewModel.input.setTabSection.send(try makeTabSection(defaultTabId: "NEWS"))

        // Then
        XCTAssertEqual(viewModel.output.selectedViewType.value, .curation)
        XCTAssertEqual(viewModel.output.tabs.value.map(\.isSelected), [false, true, false])
    }

    private func expectTabSection(_ viewModel: HomeViewModel) -> XCTestExpectation {
        let received = expectation(description: "bottomSheetTabSection")
        viewModel.output.bottomSheetTabSection
            .dropFirst()
            .first()
            .sink { _ in received.fulfill() }
            .store(in: &cancellables)
        return received
    }

    private func makeHomeViewModel(screenRepository: MockScreenRepository) -> HomeViewModel {
        HomeViewModel(dependency: .init(
            screenRepository: screenRepository,
            advertisementRepository: MockAdvertisementRepository(),
            userRepository: MockUserRepository(),
            mapRepository: MockMapRepository(),
            locationManager: MockLocationManager(),
            preference: Preference(name: "HomeTabDeepLinkTests"),
            logManager: MockLogManager()
        ))
    }

    private func makeHomeListViewModel(logManager: MockLogManager = MockLogManager()) -> HomeListViewModel {
        HomeListViewModel(dependency: .init(
            screenRepository: MockScreenRepository(),
            feedRepository: MockFeedRepository(),
            logManager: logManager,
            preference: Preference(name: "HomeTabDeepLinkTests")
        ))
    }

    private func makeTabSection(defaultTabId: String) throws -> HomeBottomSheetTabSection {
        let response = try makeResponse(defaultTabId: defaultTabId)
        return try XCTUnwrap(response.sections.compactMap { $0 as? HomeBottomSheetTabSection }.first)
    }

    private func makeResponse(defaultTabId: String) throws -> HomeFilterScreenResponse {
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "HomeFilterScreenWithNewsTab", withExtension: "json"))
        var json = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any])
        var sections = try XCTUnwrap(json["sections"] as? [[String: Any]])
        let index = try XCTUnwrap(sections.firstIndex { $0["type"] as? String == "HOME_BOTTOM_SHEET_TAB" })
        let tabs = try XCTUnwrap(sections[index]["tabs"] as? [[String: Any]])
        sections[index]["tabs"] = tabs.map { tab in
            var tab = tab
            tab["defaultSelected"] = tab["tabId"] as? String == defaultTabId
            return tab
        }
        json["sections"] = sections
        let data = try JSONSerialization.data(withJSONObject: json)
        return try JSONDecoder().decode(HomeFilterScreenResponse.self, from: data)
    }
}
