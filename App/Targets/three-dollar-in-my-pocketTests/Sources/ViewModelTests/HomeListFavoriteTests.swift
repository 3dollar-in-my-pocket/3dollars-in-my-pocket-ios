import Combine
import XCTest

import Log
import Model
@testable import Home

@MainActor
final class HomeListFavoriteTests: XCTestCase {
    private typealias Layout = HomeListStoreCell.Layout

    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    private func makeCards() throws -> [HomeListBasicCardResponse] {
        let response = try FixtureLoader.decode(HomeListSectionResponse.self, from: "HomeListSectionWithFavorite")
        return response.cards.compactMap { $0 as? HomeListBasicCardResponse }
    }

    private func makeViewModel(
        storeRepository: MockStoreRepository,
        logManager: MockLogManager = MockLogManager()
    ) -> HomeListViewModel {
        return HomeListViewModel(dependency: .init(
            screenRepository: MockScreenRepository(),
            storeRepository: storeRepository,
            feedRepository: MockFeedRepository(),
            logManager: logManager
        ))
    }

    private func waitUntilRequestFinished(_ storeRepository: MockStoreRepository) async {
        while storeRepository.saveStoreArguments.isEmpty {
            await Task.yield()
        }
        for _ in 0..<10 {
            await Task.yield()
        }
    }

    // MARK: TC-1, TC-11 — 버튼 노출과 가게명 줄 높이

    func test_TH1588_TC1_가게정보가있는카드는_찜버튼을노출하고_가게명줄높이가32다() throws {
        // Given
        let card = try XCTUnwrap(makeCards().first)

        // When
        let hasButton = Layout.hasFavoriteButton(card)
        let headerHeight = Layout.headerRowHeight(response: card)

        // Then
        XCTAssertTrue(hasButton)
        XCTAssertEqual(headerHeight, Layout.favoriteButtonSize)
    }

    func test_TH1588_TC11_가게id가없는카드는_찜버튼을숨기고_가게명줄높이가기존과같다() throws {
        // Given
        let cards = try makeCards()
        let card = try XCTUnwrap(cards.count > 2 ? cards[2] : nil)

        // When
        let hasButton = Layout.hasFavoriteButton(card)
        let headerHeight = Layout.headerRowHeight(response: card)

        // Then
        XCTAssertFalse(hasButton)
        XCTAssertEqual(headerHeight, Layout.headerHeight)
    }

    // MARK: TC-2 — 초기 찜 상태

    func test_TH1588_TC2_서버isSubscriber값으로_초기찜상태를보여준다() throws {
        // Given
        let cards = try makeCards()
        let viewModel = makeViewModel(storeRepository: MockStoreRepository())

        // When
        viewModel.input.updateCards.send(cards)

        // Then
        XCTAssertFalse(viewModel.isFavorited(cards[0]))
        XCTAssertTrue(viewModel.isFavorited(cards[1]))
        XCTAssertFalse(viewModel.isFavorited(cards[2]))
    }

    // MARK: TC-3, TC-4 — 등록·해제

    func test_TH1588_TC3_찜하지않은카드를탭하면_찜등록후_상태와토스트를갱신한다() async throws {
        // Given
        let cards = try makeCards()
        let storeRepository = MockStoreRepository()
        storeRepository.saveStoreResult = .success("")
        let viewModel = makeViewModel(storeRepository: storeRepository)
        viewModel.input.updateCards.send(cards)
        let updated = expectation(description: "favoriteUpdated")
        var updatedStoreId: String?
        var toastMessage: String?
        viewModel.output.favoriteUpdated
            .sink { updatedStoreId = $0; updated.fulfill() }
            .store(in: &cancellables)
        viewModel.output.toast
            .sink { toastMessage = $0 }
            .store(in: &cancellables)

        // When
        viewModel.input.didTapFavorite.send(cards[0].cardId)
        await fulfillment(of: [updated], timeout: 5)

        // Then
        XCTAssertEqual(storeRepository.saveStoreArguments.map(\.storeId), ["120027"])
        XCTAssertEqual(storeRepository.saveStoreArguments.map(\.isDelete), [false])
        XCTAssertEqual(updatedStoreId, cards[0].additionalInfos?.storeId)
        XCTAssertTrue(viewModel.isFavorited(cards[0]))
        XCTAssertEqual(toastMessage, HomeStrings.HomeList.Toast.addFavorite)
    }

    func test_TH1588_TC4_찜한카드를탭하면_찜해제후_상태와토스트를갱신한다() async throws {
        // Given
        let cards = try makeCards()
        let storeRepository = MockStoreRepository()
        storeRepository.saveStoreResult = .success("")
        let viewModel = makeViewModel(storeRepository: storeRepository)
        viewModel.input.updateCards.send(cards)
        let updated = expectation(description: "favoriteUpdated")
        var toastMessage: String?
        viewModel.output.favoriteUpdated
            .sink { _ in updated.fulfill() }
            .store(in: &cancellables)
        viewModel.output.toast
            .sink { toastMessage = $0 }
            .store(in: &cancellables)

        // When
        viewModel.input.didTapFavorite.send(cards[1].cardId)
        await fulfillment(of: [updated], timeout: 5)

        // Then
        XCTAssertEqual(storeRepository.saveStoreArguments.map(\.storeId), ["120009"])
        XCTAssertEqual(storeRepository.saveStoreArguments.map(\.isDelete), [true])
        XCTAssertFalse(viewModel.isFavorited(cards[1]))
        XCTAssertEqual(toastMessage, HomeStrings.HomeList.Toast.removeFavorite)
    }

    // MARK: TC-6 — 클릭 로그

    func test_TH1588_TC6_찜버튼을탭하면_클릭로그가한건전송된다() throws {
        // Given
        let cards = try makeCards()
        let logManager = MockLogManager()
        let viewModel = makeViewModel(storeRepository: MockStoreRepository(), logManager: logManager)
        viewModel.input.updateCards.send(cards)

        // When
        viewModel.input.didTapFavorite.send(cards[1].cardId)

        // Then
        XCTAssertEqual(logManager.sentEvents.count, 1)
        let event = try XCTUnwrap(logManager.sentEvents.first as? ClickEvent)
        XCTAssertEqual(event.screen, .home)
        XCTAssertEqual(event.parameters["object_type"] as? String, "button")
        XCTAssertEqual(event.parameters["object_id"] as? String, "favorite")
        XCTAssertEqual(event.parameters["store_id"] as? String, "120009")
        XCTAssertEqual(event.parameters["store_type"] as? String, "BOSS_STORE")
        XCTAssertEqual(event.parameters["value"] as? String, "off")
    }

    // MARK: TC-7 — 실패

    func test_TH1588_TC7_찜API가실패하면_상태를바꾸지않고_토스트를띄우지않는다() async throws {
        // Given
        let cards = try makeCards()
        let storeRepository = MockStoreRepository()
        let viewModel = makeViewModel(storeRepository: storeRepository)
        viewModel.input.updateCards.send(cards)
        var updatedCount = 0
        var toastCount = 0
        viewModel.output.favoriteUpdated
            .sink { _ in updatedCount += 1 }
            .store(in: &cancellables)
        viewModel.output.toast
            .sink { _ in toastCount += 1 }
            .store(in: &cancellables)

        // When
        viewModel.input.didTapFavorite.send(cards[0].cardId)
        await waitUntilRequestFinished(storeRepository)

        // Then
        XCTAssertEqual(storeRepository.saveStoreArguments.count, 1)
        XCTAssertFalse(viewModel.isFavorited(cards[0]))
        XCTAssertEqual(updatedCount, 0)
        XCTAssertEqual(toastCount, 0)
    }

    // MARK: TC-8 — 연타

    func test_TH1588_TC8_요청이끝나기전에다시탭하면_요청은한번만나간다() async throws {
        // Given
        let cards = try makeCards()
        let storeRepository = MockStoreRepository()
        storeRepository.saveStoreResult = .success("")
        let viewModel = makeViewModel(storeRepository: storeRepository)
        viewModel.input.updateCards.send(cards)
        let updated = expectation(description: "favoriteUpdated")
        viewModel.output.favoriteUpdated
            .sink { _ in updated.fulfill() }
            .store(in: &cancellables)

        // When
        viewModel.input.didTapFavorite.send(cards[0].cardId)
        viewModel.input.didTapFavorite.send(cards[0].cardId)
        await fulfillment(of: [updated], timeout: 5)

        // Then
        XCTAssertEqual(storeRepository.saveStoreArguments.count, 1)
        XCTAssertTrue(viewModel.isFavorited(cards[0]))
    }

    // MARK: TC-10 — 페이지 추가·목록 교체

    func test_TH1588_TC10_다음페이지가붙어도_바꾼찜상태를유지하고_목록이교체되면_서버값을따른다() async throws {
        // Given
        let cards = try makeCards()
        let storeRepository = MockStoreRepository()
        storeRepository.saveStoreResult = .success("")
        let viewModel = makeViewModel(storeRepository: storeRepository)
        viewModel.input.updateCards.send(cards)
        let updated = expectation(description: "favoriteUpdated")
        viewModel.output.favoriteUpdated
            .sink { _ in updated.fulfill() }
            .store(in: &cancellables)
        viewModel.input.didTapFavorite.send(cards[0].cardId)
        await fulfillment(of: [updated], timeout: 5)

        // When
        viewModel.input.updateCards.send(cards + cards)

        // Then
        XCTAssertTrue(viewModel.isFavorited(cards[0]))
        XCTAssertTrue(viewModel.isFavorited(cards[1]))

        // When
        viewModel.input.didReplaceCards.send(())

        // Then
        XCTAssertFalse(viewModel.isFavorited(cards[0]))
        XCTAssertTrue(viewModel.isFavorited(cards[1]))
    }

    // MARK: TC-13 — 미리보기 시트 찜 동기화

    func test_TH1588_TC13_미리보기시트에서찜이바뀌면_같은가게카드상태가갱신된다() throws {
        // Given
        let cards = try makeCards()
        let viewModel = makeViewModel(storeRepository: MockStoreRepository())
        viewModel.input.updateCards.send(cards)
        var updatedStoreIds: [String] = []
        viewModel.output.favoriteUpdated
            .sink { updatedStoreIds.append($0) }
            .store(in: &cancellables)

        // When
        viewModel.input.updateFavorite.send((storeId: "120027", isFavorited: true))

        // Then
        XCTAssertTrue(viewModel.isFavorited(cards[0]))
        XCTAssertEqual(updatedStoreIds, ["120027"])
    }
}
