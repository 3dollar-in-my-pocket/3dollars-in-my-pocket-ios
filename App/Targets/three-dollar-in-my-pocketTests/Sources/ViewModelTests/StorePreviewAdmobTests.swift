import Combine
import XCTest

import Log
import Model
@testable import Home

final class StorePreviewAdmobTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: TC-1 — 애드몹이 맨 위

    func test_TH1591_TC1_애드몹이맨위인응답이면_애드몹다음에미리보기순서로시트섹션이전달된다() throws {
        // Given
        let response = try FixtureLoader.decode(StorePreviewScreenResponse.self, from: "StorePreviewWithAdmob")
        let viewModel = makeViewModel(response: response)

        // When
        let sections = try loadSections(viewModel)

        // Then
        XCTAssertEqual(sections.map(\.type), [.admob, .preview])
    }

    // MARK: TC-2 — 서버 순서

    func test_TH1591_TC2_애드몹이미리보기아래인응답이면_서버순서대로미리보기다음에애드몹이전달된다() throws {
        // Given
        let response = try FixtureLoader.decode(StorePreviewScreenResponse.self, from: "StorePreviewWithAdmobBelowPreview")
        let viewModel = makeViewModel(response: response)

        // When
        let sections = try loadSections(viewModel)

        // Then
        XCTAssertEqual(sections.map(\.type), [.preview, .admob])
    }

    // MARK: TC-3 — 애드몹 없음

    func test_TH1591_TC3_애드몹섹션이없는응답이면_미리보기섹션만전달된다() throws {
        // Given
        let json = """
        {
          "sections": [
            {
              "type": "PREVIEW",
              "header": { "title": { "text": "가게", "isHtml": false, "fontColor": "#0F0F0F" } },
              "metadata": { "primary": [], "secondary": [], "separator": { "url": "https://example.com/dot.png", "style": { "width": 2.0, "height": 2.0 } } },
              "actionBars": [],
              "images": [],
              "bodies": [],
              "additionalInfos": { "type": "STORE", "isSubscriber": false, "storeId": "55", "storeType": "USER_STORE" }
            }
          ],
          "viewLog": { "screenName": "home_store_preview", "extraParameters": {} }
        }
        """
        let response = try JSONDecoder().decode(StorePreviewScreenResponse.self, from: Data(json.utf8))
        let viewModel = makeViewModel(response: response)

        // When
        let sections = try loadSections(viewModel)

        // Then
        XCTAssertEqual(sections.map(\.type), [.preview])
    }

    // MARK: TC-6 — 노출 로그

    func test_TH1591_TC6_미리보기애드몹이노출되면_섹션과카드노출로그를서버값그대로한건씩보낸다() throws {
        // Given
        let response = try FixtureLoader.decode(StorePreviewScreenResponse.self, from: "StorePreviewWithAdmob")
        let admob = try XCTUnwrap(response.sections.compactMap { $0 as? StoreAdmobSection }.first)
        let logManager = MockLogManager()
        let viewModel = makeViewModel(response: response, logManager: logManager)

        // When
        viewModel.input.didImpression.send(admob.impressionLog)
        viewModel.input.didImpression.send(admob.cards.first?.impressionLog)

        // Then
        let events = logManager.sentEvents.compactMap { $0 as? ImpressionEvent }
        XCTAssertEqual(events.count, 2)
        XCTAssertEqual(events.map(\.screen.rawValue), ["store_bottom_sheet", "store_bottom_sheet"])
        XCTAssertEqual(events[0].parameters["object_type"] as? String, "section")
        XCTAssertEqual(events[0].parameters["section_type"] as? String, "AD_MOB")
        XCTAssertEqual(events[1].parameters["object_type"] as? String, "card")
        XCTAssertEqual(events[1].parameters["object_id"] as? String, "admob")
        XCTAssertEqual(events[1].parameters["store_id"] as? String, "12806182")
    }

    // MARK: TC-7 — 클릭 로그

    func test_TH1591_TC7_미리보기애드몹을클릭하면_카드클릭로그를보낸다() throws {
        // Given
        let response = try FixtureLoader.decode(StorePreviewScreenResponse.self, from: "StorePreviewWithAdmob")
        let admob = try XCTUnwrap(response.sections.compactMap { $0 as? StoreAdmobSection }.first)
        let logManager = MockLogManager()
        let viewModel = makeViewModel(response: response, logManager: logManager)

        // When
        viewModel.input.didClickAd.send(admob.cards.first?.clickLog)

        // Then
        XCTAssertEqual(logManager.sentEvents.count, 1)
        let event = try XCTUnwrap(logManager.sentEvents.first as? ClickEvent)
        XCTAssertEqual(event.screen.rawValue, "store_bottom_sheet")
        XCTAssertEqual(event.parameters["object_type"] as? String, "card")
        XCTAssertEqual(event.parameters["object_id"] as? String, "admob")
    }

    // MARK: TC-8 — 알 수 없는 섹션

    func test_TH1591_TC8_미리보기응답에모르는섹션이있으면_그섹션만빼고애드몹과미리보기를디코딩한다() throws {
        // When
        let response = try FixtureLoader.decode(StorePreviewScreenResponse.self, from: "StorePreviewWithAdmob")

        // Then
        XCTAssertEqual(response.sections.map(\.type), [.admob, .preview])
        let admob = try XCTUnwrap(response.sections.first as? StoreAdmobSection)
        XCTAssertEqual(admob.cards.first?.height, 50)
        XCTAssertEqual(admob.cards.first?.adUnitId, "ca-app-pub-5385646520024289/7789991453")
        XCTAssertNotNil(response.previewSection)
    }

    private func loadSections(_ viewModel: StorePreviewBottomSheetViewModel) throws -> [any StoreSectionComponent] {
        let sectionsExpectation = expectation(description: "sections")
        var received: [any StoreSectionComponent] = []
        viewModel.output.sections.sink { sections in
            received = sections
            sectionsExpectation.fulfill()
        }.store(in: &cancellables)

        viewModel.input.load.send(())

        wait(for: [sectionsExpectation], timeout: 2)
        return received
    }

    private func makeViewModel(
        response: StorePreviewScreenResponse,
        logManager: MockLogManager = MockLogManager()
    ) -> StorePreviewBottomSheetViewModel {
        let repository = MockStoreRepository()
        repository.fetchStorePreviewResult = .success(response)
        return StorePreviewBottomSheetViewModel(
            config: .init(storeId: 12806182, latitude: 37.5, longitude: 127.0),
            dependency: .init(storeRepository: repository, logManager: logManager)
        )
    }
}
