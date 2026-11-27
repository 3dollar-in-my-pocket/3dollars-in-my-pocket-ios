import Combine
import XCTest

import Common
import FeedInterface
import Log
import Model
@testable import Feed

@MainActor
final class LocalNewsListViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    private let request = FeedListViewModel.LoadRequest(
        newsTabId: "NEWS",
        latitude: 37.3617,
        longitude: 126.9352,
        maxDistanceM: 4200
    )
    private let admobCardId = "ADMOB:145b038d-74f8-4cb6-b18e-1607d52ed712"
    private let visitCardId = "NEWS:6b03d032fdb9ab52247e1939"
    private let reviewCardId = "NEWS:6af4a1f27af92de3599ff76b"

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: TH-1558 TC1

    func test_TH1558_TC1_소식을불러오면_탭ID와지도좌표반경으로조회하고_서버헤더아래에서버순서대로보여준다() async throws {
        // Given
        let screenRepository = try makeRepository()
        let viewModel = makeViewModel(screenRepository: screenRepository)
        let loaded = expectItems(viewModel) { $0.contains { $0.cardId != nil } }

        // When
        viewModel.input.load.send(request)

        // Then
        await fulfillment(of: [loaded], timeout: 1)
        let call = try XCTUnwrap(screenRepository.fetchHomeNewsSectionCalls.first)
        XCTAssertEqual(call.newsTabId, "NEWS")
        XCTAssertEqual(call.input, FetchHomeNewsSectionInput(mapLatitude: 37.3617, mapLongitude: 126.9352, maxDistanceM: 4200))
        let items = currentItems(viewModel)
        guard case .header(let header) = items.first else { return XCTFail("헤더가 첫 줄이 아니다") }
        XCTAssertTrue(header.title.text.contains("우리 동네 가게 소식"))
        XCTAssertEqual(items.dropFirst().compactMap(\.cardId), [admobCardId, visitCardId, reviewCardId])
    }

    // MARK: TH-1558 TC3

    func test_TH1558_TC3_광고카드는_서버가준자리에만있고_앱이고정으로끼워넣는광고자리는없다() async throws {
        // Given
        let viewModel = makeViewModel(screenRepository: try makeRepository())
        let loaded = expectItems(viewModel) { $0.contains { $0.cardId != nil } }

        // When
        viewModel.input.load.send(request)

        // Then
        await fulfillment(of: [loaded], timeout: 1)
        let items = currentItems(viewModel)
        let admobIndices = items.indices.filter { if case .admobCard = items[$0] { return true } else { return false } }
        XCTAssertEqual(admobIndices, [1])
        XCTAssertEqual(items.count, 4)
    }

    // MARK: TH-1558 TC4

    func test_TH1558_TC4_마지막카드가보이고다음페이지가있으면_nextCursor로이어불러오고_받은카드는다시붙이지않는다() async throws {
        // Given
        let first = try makeResponse()
        let second = try makeResponse { json in
            var items = try XCTUnwrap(json["items"] as? [[String: Any]])
            var newCard = items[1]
            newCard["cardId"] = "NEWS:next-page"
            items = [items[2], newCard]
            json["items"] = items
            json["cursor"] = ["hasMore": false]
        }
        let screenRepository = MockScreenRepository()
        screenRepository.fetchHomeNewsSectionHandler = { callCount in
            callCount == 1 ? .success(first) : .success(second)
        }
        let viewModel = makeViewModel(screenRepository: screenRepository)
        let loaded = expectItems(viewModel) { $0.contains { $0.cardId != nil } }
        viewModel.input.load.send(request)
        await fulfillment(of: [loaded], timeout: 1)
        let nextPage = expectItems(viewModel) { $0.contains { $0.cardId == "NEWS:next-page" } }

        // When
        viewModel.input.willDisplayCell.send(currentItems(viewModel).count - 1)

        // Then
        await fulfillment(of: [nextPage], timeout: 1)
        XCTAssertEqual(screenRepository.fetchHomeNewsSectionCalls.map(\.input.cursor), [nil, first.cursor.nextCursor])
        XCTAssertEqual(
            currentItems(viewModel).compactMap(\.cardId),
            [admobCardId, visitCardId, reviewCardId, "NEWS:next-page"]
        )
    }

    func test_TH1558_TC4_다음페이지가없으면_마지막카드가보여도_더불러오지않는다() async throws {
        // Given
        let response = try makeResponse { $0["cursor"] = ["hasMore": false] }
        let screenRepository = MockScreenRepository()
        screenRepository.fetchHomeNewsSectionResult = .success(response)
        let viewModel = makeViewModel(screenRepository: screenRepository)
        let loaded = expectItems(viewModel) { $0.contains { $0.cardId != nil } }
        viewModel.input.load.send(request)
        await fulfillment(of: [loaded], timeout: 1)

        // When
        viewModel.input.willDisplayCell.send(currentItems(viewModel).count - 1)
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertEqual(screenRepository.fetchHomeNewsSectionCalls.count, 1)
    }

    // MARK: TH-1558 TC5

    func test_TH1558_TC5_소식카드를누르면_카드link로이동하고_카드클릭로그를한번보낸다() async throws {
        // Given
        let logManager = MockLogManager()
        let viewModel = makeViewModel(screenRepository: try makeRepository(), logManager: logManager)
        try await load(viewModel)
        var routes: [FeedListViewModel.Route] = []
        viewModel.output.route
            .sink { routes.append($0) }
            .store(in: &cancellables)

        // When
        viewModel.input.didTapCard.send(visitCardId)

        // Then
        guard case .deepLink(let link) = routes.first else { return XCTFail("딥링크 Route가 없다") }
        XCTAssertEqual(link.type, .appScheme)
        XCTAssertEqual(link.link, "/store?storeId=530045&storeType=USER_STORE&view=collapsed")
        let clicks = logManager.sentEvents.filter { $0.name == .click }
        XCTAssertEqual(clicks.count, 1)
        XCTAssertEqual(clicks.first?.screen.rawValue, "home")
        XCTAssertEqual(clicks.first?.parameters["object_id"] as? String, "home_news_card")
        XCTAssertEqual(clicks.first?.parameters["feed_id"] as? String, "6b03d032fdb9ab52247e1939")
    }

    // MARK: TH-1558 TC6

    func test_TH1558_TC6_소식카드와광고카드가보이면_카드마다노출로그를한번만보낸다() async throws {
        // Given
        let logManager = MockLogManager()
        let viewModel = makeViewModel(screenRepository: try makeRepository(), logManager: logManager)
        try await load(viewModel)

        // When
        viewModel.input.willDisplayCell.send(0)
        viewModel.input.willDisplayCell.send(1)
        viewModel.input.willDisplayCell.send(2)
        viewModel.input.willDisplayCell.send(2)

        // Then
        let cardImpressions = logManager.sentEvents.filter {
            $0.name.rawValue == EventName.impression.rawValue && $0.parameters["object_type"] as? String == "card"
        }
        XCTAssertEqual(cardImpressions.compactMap { $0.parameters["object_id"] as? String }, ["admob", "home_news_card"])
        XCTAssertEqual(cardImpressions.last?.parameters["position"] as? String, "2")
    }

    func test_TH1558_TC6_광고를누르면_광고클릭로그를보낸다() async throws {
        // Given
        let logManager = MockLogManager()
        let viewModel = makeViewModel(screenRepository: try makeRepository(), logManager: logManager)
        try await load(viewModel)

        // When
        viewModel.input.didTapAdmob.send(admobCardId)

        // Then
        let clicks = logManager.sentEvents.filter { $0.name == .click }
        XCTAssertEqual(clicks.count, 1)
        XCTAssertEqual(clicks.first?.parameters["object_id"] as? String, "admob")
        XCTAssertEqual(clicks.first?.parameters["tabId"] as? String, "NEWS")
    }

    // MARK: TH-1558 TC7

    func test_TH1558_TC7_첫페이지를받으면_섹션노출로그를한번넘기고_다음페이지에서는넘기지않는다() async throws {
        // Given
        let first = try makeResponse()
        let screenRepository = MockScreenRepository()
        screenRepository.fetchHomeNewsSectionResult = .success(first)
        let viewModel = makeViewModel(screenRepository: screenRepository)
        var sectionLogs: [SDImpressionLog] = []
        viewModel.output.sectionImpressionLog
            .sink { sectionLogs.append($0) }
            .store(in: &cancellables)
        try await load(viewModel)
        let nextPage = expectation(description: "next page")
        nextPage.assertForOverFulfill = false
        viewModel.output.datasource
            .dropFirst()
            .sink { _ in nextPage.fulfill() }
            .store(in: &cancellables)

        // When
        viewModel.input.willDisplayCell.send(currentItems(viewModel).count - 1)

        // Then
        await fulfillment(of: [nextPage], timeout: 1)
        XCTAssertEqual(screenRepository.fetchHomeNewsSectionCalls.count, 2)
        XCTAssertEqual(sectionLogs.map(\.objectId), ["home_news"])
    }

    // MARK: TH-1558 TC8

    func test_TH1558_TC8_본문사진을누르면_누른사진부터크게보기를연다() async throws {
        // Given
        let viewModel = makeViewModel(screenRepository: try makeRepository())
        try await load(viewModel)
        var routes: [FeedListViewModel.Route] = []
        viewModel.output.route
            .sink { routes.append($0) }
            .store(in: &cancellables)

        // When
        viewModel.input.didTapImage.send(.init(cardId: reviewCardId, blockIndex: 0, imageIndex: 1))

        // Then
        guard case .presentPhotoViewer(let imageUrls, let selectedIndex) = routes.first else {
            return XCTFail("크게 보기 Route가 없다")
        }
        XCTAssertEqual(imageUrls.count, 2)
        XCTAssertTrue(imageUrls[1].contains("v1-8238e194"))
        XCTAssertEqual(selectedIndex, 1)
    }

    // MARK: TH-1558 TC9

    func test_TH1558_TC9_items가비어있으면_헤더아래빈상태만보여준다() async throws {
        // Given
        let screenRepository = MockScreenRepository()
        screenRepository.fetchHomeNewsSectionResult = .success(try makeResponse {
            $0["items"] = []
            $0["cursor"] = ["hasMore": false]
        })
        let viewModel = makeViewModel(screenRepository: screenRepository)
        let loaded = expectItems(viewModel) { $0.contains(.empty) }

        // When
        viewModel.input.load.send(request)

        // Then
        await fulfillment(of: [loaded], timeout: 1)
        let items = currentItems(viewModel)
        XCTAssertEqual(items.count, 2)
        guard case .header = items.first else { return XCTFail("헤더가 첫 줄이 아니다") }
        XCTAssertEqual(items.last, .empty)
    }

    // MARK: TH-1558 TC11

    func test_TH1558_TC11_불러오는동안_스켈레톤3개를보여준다() {
        // Given
        let viewModel = makeViewModel(screenRepository: MockScreenRepository())

        // When
        viewModel.input.load.send(request)

        // Then
        XCTAssertEqual(currentItems(viewModel), [.skeleton(0), .skeleton(1), .skeleton(2)])
    }

    func test_TH1558_TC11_조회에실패하면_다시시도를보여주고_다시시도하면다시불러온다() async throws {
        // Given
        let response = try makeResponse()
        let screenRepository = MockScreenRepository()
        screenRepository.fetchHomeNewsSectionHandler = { callCount in
            callCount == 1 ? .failure(MockError.notStubbed()) : .success(response)
        }
        let viewModel = makeViewModel(screenRepository: screenRepository)
        let failed = expectItems(viewModel) { $0.contains(.error) }
        viewModel.input.load.send(request)
        await fulfillment(of: [failed], timeout: 1)
        let reloaded = expectItems(viewModel) { $0.contains { $0.cardId != nil } }

        // When
        viewModel.input.retry.send(())

        // Then
        await fulfillment(of: [reloaded], timeout: 1)
        XCTAssertEqual(screenRepository.fetchHomeNewsSectionCalls.count, 2)
        XCTAssertFalse(currentItems(viewModel).contains(.error))
    }

    // MARK: TH-1558 TC12

    func test_TH1558_TC12_새좌표로다시불러오면_새좌표로조회하고_맨위로이동한다() async throws {
        // Given
        let screenRepository = try makeRepository()
        let viewModel = makeViewModel(screenRepository: screenRepository)
        var scrollToTopCount = 0
        viewModel.output.scrollToTop
            .sink { scrollToTopCount += 1 }
            .store(in: &cancellables)
        try await load(viewModel)

        // When
        viewModel.input.load.send(.init(newsTabId: "NEWS", latitude: 37.5665, longitude: 126.9780, maxDistanceM: nil))

        // Then
        await waitUntil { screenRepository.fetchHomeNewsSectionCalls.count == 2 && currentItems(viewModel).contains { $0.cardId != nil } }
        XCTAssertEqual(screenRepository.fetchHomeNewsSectionCalls.map(\.input.mapLatitude), [37.3617, 37.5665])
        XCTAssertEqual(scrollToTopCount, 2)
    }

    // MARK: TH-1593 TC4

    func test_TH1593_TC4_반경과함께불러오면_첫페이지와다음페이지요청에모두반경이담긴다() async throws {
        // Given
        let screenRepository = try makeRepository()
        let viewModel = makeViewModel(screenRepository: screenRepository)
        try await load(viewModel)
        let nextPage = expectation(description: "next page")
        nextPage.assertForOverFulfill = false
        viewModel.output.datasource
            .dropFirst()
            .sink { _ in nextPage.fulfill() }
            .store(in: &cancellables)

        // When
        viewModel.input.willDisplayCell.send(currentItems(viewModel).count - 1)

        // Then
        await fulfillment(of: [nextPage], timeout: 1)
        XCTAssertEqual(screenRepository.fetchHomeNewsSectionCalls.map(\.input.maxDistanceM), [4200, 4200])
    }

    // MARK: TH-1593 TC6

    func test_TH1593_TC6_반경을모르면_요청파라미터에maxDistanceM이없다() throws {
        // Given
        let input = FetchHomeNewsSectionInput(mapLatitude: 37.4979, mapLongitude: 127.0276, maxDistanceM: nil)

        // When
        let json = try JSONSerialization.jsonObject(with: JSONEncoder().encode(input)) as? [String: Any]

        // Then
        XCTAssertNil(json?["maxDistanceM"])
        XCTAssertNil(json?["cursor"])
        XCTAssertEqual(json?["mapLatitude"] as? Double, 37.4979)
    }

    // MARK: - Helpers

    private func makeViewModel(
        screenRepository: MockScreenRepository,
        logManager: MockLogManager = MockLogManager()
    ) -> FeedListViewModel {
        FeedListViewModel(dependency: FeedListViewModelDependency(
            screenRepository: screenRepository,
            logManager: logManager
        ))
    }

    private func makeRepository() throws -> MockScreenRepository {
        let repository = MockScreenRepository()
        repository.fetchHomeNewsSectionResult = .success(try makeResponse())
        return repository
    }

    private func makeResponse(_ modify: ((inout [String: Any]) throws -> Void)? = nil) throws -> HomeNewsSectionResponse {
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "HomeNewsSection", withExtension: "json"))
        var json = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any])
        try modify?(&json)
        return try JSONDecoder().decode(HomeNewsSectionResponse.self, from: JSONSerialization.data(withJSONObject: json))
    }

    private func load(_ viewModel: FeedListViewModel) async throws {
        let loaded = expectItems(viewModel) { $0.contains { $0.cardId != nil } }
        viewModel.input.load.send(request)
        await fulfillment(of: [loaded], timeout: 1)
    }

    private func waitUntil(_ condition: () -> Bool) async {
        var attempts = 0
        while condition().isNot, attempts < 100 {
            attempts += 1
            try? await Task.sleep(nanoseconds: 20_000_000)
        }
    }

    private func currentItems(_ viewModel: FeedListViewModel) -> [FeedListSectionItem] {
        viewModel.output.datasource.value.first?.items ?? []
    }

    private func expectItems(
        _ viewModel: FeedListViewModel,
        where predicate: @escaping ([FeedListSectionItem]) -> Bool
    ) -> XCTestExpectation {
        let matched = expectation(description: "items")
        matched.assertForOverFulfill = false
        viewModel.output.datasource
            .map { $0.first?.items ?? [] }
            .filter(predicate)
            .sink { _ in matched.fulfill() }
            .store(in: &cancellables)
        return matched
    }
}
