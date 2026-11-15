import Combine
import XCTest

import FeedInterface
import Model
@testable import Feed

@MainActor
final class LocalNewsListViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: TH-1426 TC2

    func test_TH1426_TC2_지도좌표로불러오면_목록머리아래에소식이최신순으로보인다() async throws {
        // Given
        let feedRepository = MockFeedRepository()
        feedRepository.fetchFeedResults = [.success(try makeFeeds())]
        let viewModel = makeViewModel(feedRepository: feedRepository)
        let loaded = expectItems(viewModel) { $0.contains { $0.feedId != nil } }

        // When
        viewModel.input.load.send(.init(latitude: 37.4979, longitude: 127.0276, maxDistanceM: nil))

        // Then
        await fulfillment(of: [loaded], timeout: 1)
        let items = currentItems(viewModel)
        XCTAssertEqual(items.first, .header)
        XCTAssertEqual(items.compactMap(\.feedId), ["6ad7645103e011c1ebc9ffd5", "6ad390b8279bd19eba6157f5"])
        XCTAssertEqual(feedRepository.requestedInputs.first?.mapLatitude, 37.4979)
        XCTAssertEqual(feedRepository.requestedInputs.first?.mapLongitude, 127.0276)
        XCTAssertNil(feedRepository.requestedInputs.first?.cursor)
    }

    // MARK: TH-1426 TC3

    func test_TH1426_TC3_마지막소식이보이고다음페이지가있으면_다음커서로이어서불러온다() async throws {
        // Given
        let feedRepository = MockFeedRepository()
        feedRepository.fetchFeedResults = [
            .success(try makeFeeds(cursor: ["hasMore": true, "nextCursor": "NEXT"])),
            .success(try makeFeeds(contents: []))
        ]
        let viewModel = makeViewModel(feedRepository: feedRepository)
        let loaded = expectItems(viewModel) { $0.contains { $0.feedId != nil } }
        viewModel.input.load.send(.init(latitude: 37.4979, longitude: 127.0276, maxDistanceM: nil))
        await fulfillment(of: [loaded], timeout: 1)
        let nextPage = expectation(description: "next page")
        viewModel.output.datasource
            .dropFirst()
            .sink { _ in nextPage.fulfill() }
            .store(in: &cancellables)

        // When
        viewModel.input.willDisplayCell.send(currentItems(viewModel).count - 1)

        // Then
        await fulfillment(of: [nextPage], timeout: 1)
        XCTAssertEqual(feedRepository.requestedInputs.map(\.cursor), [nil, "NEXT"])
    }

    // MARK: TH-1426 TC4

    func test_TH1426_TC4_새좌표로다시불러오면_목록을새로받고_맨위로이동한다() async throws {
        // Given
        let feedRepository = MockFeedRepository()
        feedRepository.fetchFeedResults = [.success(try makeFeeds())]
        let viewModel = makeViewModel(feedRepository: feedRepository)
        var scrollToTopCount = 0
        viewModel.output.scrollToTop
            .sink { scrollToTopCount += 1 }
            .store(in: &cancellables)

        // When
        viewModel.input.load.send(.init(latitude: 37.4979, longitude: 127.0276, maxDistanceM: nil))
        viewModel.input.load.send(.init(latitude: 37.5665, longitude: 126.9780, maxDistanceM: nil))

        // Then
        var yieldCount = 0
        while feedRepository.requestedInputs.count < 2, yieldCount < 1000 {
            await Task.yield()
            yieldCount += 1
        }
        let loaded = expectItems(viewModel) { $0.contains { $0.feedId != nil } }
        await fulfillment(of: [loaded], timeout: 1)
        XCTAssertEqual(Set(feedRepository.requestedInputs.compactMap(\.mapLatitude)), [37.4979, 37.5665])
        XCTAssertEqual(scrollToTopCount, 2)
    }

    // MARK: TH-1426 TC6

    func test_TH1426_TC6_지도영역에소식이없으면_빈상태를보여준다() async throws {
        // Given
        let feedRepository = MockFeedRepository()
        feedRepository.fetchFeedResults = [.success(try makeFeeds(contents: []))]
        let viewModel = makeViewModel(feedRepository: feedRepository)
        let loaded = expectItems(viewModel) { $0.contains(.empty) }

        // When
        viewModel.input.load.send(.init(latitude: 37.4979, longitude: 127.0276, maxDistanceM: nil))

        // Then
        await fulfillment(of: [loaded], timeout: 1)
        XCTAssertEqual(currentItems(viewModel).first, .header)
    }

    // MARK: TH-1426 TC7

    func test_TH1426_TC7_소식조회에실패하면_다시시도상태를보여주고_다시시도하면다시불러온다() async throws {
        // Given
        let feedRepository = MockFeedRepository()
        feedRepository.fetchFeedResults = [.failure(MockError.notStubbed()), .success(try makeFeeds())]
        let viewModel = makeViewModel(feedRepository: feedRepository)
        let failed = expectItems(viewModel) { $0.contains(.error) }
        viewModel.input.load.send(.init(latitude: 37.4979, longitude: 127.0276, maxDistanceM: nil))
        await fulfillment(of: [failed], timeout: 1)
        let reloaded = expectItems(viewModel) { $0.contains { $0.feedId != nil } }

        // When
        viewModel.input.retry.send(())

        // Then
        await fulfillment(of: [reloaded], timeout: 1)
        XCTAssertEqual(feedRepository.requestedInputs.count, 2)
        XCTAssertFalse(currentItems(viewModel).contains(.error))
    }

    // MARK: TH-1426 TC8

    func test_TH1426_TC8_소식을불러오는동안_스켈레톤3개를보여준다() throws {
        // Given
        let viewModel = makeViewModel(feedRepository: MockFeedRepository())

        // When
        viewModel.input.load.send(.init(latitude: 37.4979, longitude: 127.0276, maxDistanceM: nil))

        // Then
        XCTAssertEqual(currentItems(viewModel), [.header, .skeleton(0), .advertisement(nil), .skeleton(1), .skeleton(2)])
    }

    // MARK: TH-1426 TC18

    func test_TH1426_TC18_소식이있으면_첫소식아래두번째자리에_지역소식광고슬롯이있다() async throws {
        // Given
        let feedRepository = MockFeedRepository()
        feedRepository.fetchFeedResults = [.success(try makeFeeds())]
        let viewModel = makeViewModel(feedRepository: feedRepository)
        let loaded = expectItems(viewModel) { $0.contains { $0.feedId != nil } }

        // When
        viewModel.input.load.send(.init(latitude: 37.4979, longitude: 127.0276, maxDistanceM: nil))

        // Then
        await fulfillment(of: [loaded], timeout: 1)
        let items = currentItems(viewModel)
        XCTAssertEqual(items.first, .header)
        XCTAssertEqual(items[1].feedId, "6ad7645103e011c1ebc9ffd5")
        XCTAssertEqual(items[2], .advertisement(nil))
        XCTAssertEqual(items[3].feedId, "6ad390b8279bd19eba6157f5")
    }

    // MARK: TH-1426 TC20

    func test_TH1426_TC20_소식이없으면_빈상태아래에_지역소식광고슬롯이있다() async throws {
        // Given
        let feedRepository = MockFeedRepository()
        feedRepository.fetchFeedResults = [.success(try makeFeeds(contents: []))]
        let viewModel = makeViewModel(feedRepository: feedRepository)
        let loaded = expectItems(viewModel) { $0.contains(.empty) }

        // When
        viewModel.input.load.send(.init(latitude: 37.4979, longitude: 127.0276, maxDistanceM: nil))

        // Then
        await fulfillment(of: [loaded], timeout: 1)
        XCTAssertEqual(currentItems(viewModel), [.header, .empty, .advertisement(nil)])
    }

    // MARK: - Helpers

    // MARK: TH-1593 TC4

    func test_TH1593_TC4_반경과함께불러오면_첫페이지와다음페이지요청에모두반경이담긴다() async throws {
        // Given
        let feedRepository = MockFeedRepository()
        feedRepository.fetchFeedResults = [
            .success(try makeFeeds(cursor: ["hasMore": true, "nextCursor": "NEXT"])),
            .success(try makeFeeds(contents: []))
        ]
        let viewModel = makeViewModel(feedRepository: feedRepository)
        let loaded = expectItems(viewModel) { $0.contains { $0.feedId != nil } }
        viewModel.input.load.send(.init(latitude: 37.4979, longitude: 127.0276, maxDistanceM: 4200))
        await fulfillment(of: [loaded], timeout: 1)
        let nextPage = expectation(description: "next page")
        viewModel.output.datasource
            .dropFirst()
            .sink { _ in nextPage.fulfill() }
            .store(in: &cancellables)

        // When
        viewModel.input.willDisplayCell.send(currentItems(viewModel).count - 1)

        // Then
        await fulfillment(of: [nextPage], timeout: 1)
        XCTAssertEqual(feedRepository.requestedInputs.map(\.cursor), [nil, "NEXT"])
        XCTAssertEqual(feedRepository.requestedInputs.map(\.maxDistanceM), [4200, 4200])
    }

    // MARK: TH-1593 TC6

    func test_TH1593_TC6_반경을모르면_요청파라미터에maxDistanceM이없다() throws {
        // Given
        let input = FetchFeedInput(mapLatitude: 37.4979, mapLongitude: 127.0276, maxDistanceM: nil)

        // When
        let json = try JSONSerialization.jsonObject(with: JSONEncoder().encode(input)) as? [String: Any]

        // Then
        XCTAssertNil(json?["maxDistanceM"])
        XCTAssertEqual(json?["mapLatitude"] as? Double, 37.4979)
    }

    private func makeViewModel(feedRepository: MockFeedRepository) -> FeedListViewModel {
        FeedListViewModel(dependency: FeedListViewModelDependency(
            feedRepository: feedRepository,
            advertisementRepository: MockAdvertisementRepository()
        ))
    }

    private func makeFeeds(
        contents: [[String: Any]]? = nil,
        cursor: [String: Any] = ["hasMore": false]
    ) throws -> ContentsWithCursorResponse<FeedResponse> {
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "LocalNewsFeeds", withExtension: "json"))
        var json = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any])
        if let contents {
            json["contents"] = contents
        }
        json["cursor"] = cursor
        return try JSONDecoder().decode(
            ContentsWithCursorResponse<FeedResponse>.self,
            from: JSONSerialization.data(withJSONObject: json)
        )
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

private extension FeedListSectionItem {
    var feedId: String? {
        guard case .feed(let feed) = self else { return nil }
        return feed.feedId
    }
}
