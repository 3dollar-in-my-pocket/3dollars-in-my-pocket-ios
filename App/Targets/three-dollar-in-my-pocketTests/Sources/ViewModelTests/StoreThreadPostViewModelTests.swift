import Combine
import XCTest

import Log
import Model
import Networking
@testable import Store

final class StoreThreadPostViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func test_TH1448_TC8_일부permalink의oEmbed가실패하면_실패한카드만빠지고나머지는노출된다() async throws {
        // Given
        let succeededPermalink = StoreThreadPostFixture.permalinks[0]
        let threadsRepository = MockThreadsRepository(htmlsByURL: [succeededPermalink: "<blockquote>ok</blockquote>"])
        let viewModel = try makeViewModel(threadsRepository: threadsRepository)
        let resolvedSection = expectResolvedThreadPostSection(from: viewModel)

        // When
        viewModel.input.load.send(())

        // Then
        await fulfillment(of: [resolvedSection.expectation], timeout: 2)
        let embeds = try XCTUnwrap(resolvedSection.value()?.embeds)
        XCTAssertEqual(embeds.map(\.permalink), [succeededPermalink])
        XCTAssertEqual(embeds.first?.html, "<blockquote>ok</blockquote>")
        XCTAssertEqual(Set(threadsRepository.requestedURLs), Set(StoreThreadPostFixture.permalinks))
    }

    func test_TH1448_TC9_모든permalink의oEmbed가실패하면_노출할카드가없어섹션이숨겨진다() async throws {
        // Given
        let viewModel = try makeViewModel(threadsRepository: MockThreadsRepository())
        let resolvedSection = expectResolvedThreadPostSection(from: viewModel)

        // When
        viewModel.input.load.send(())

        // Then
        await fulfillment(of: [resolvedSection.expectation], timeout: 2)
        let embeds = try XCTUnwrap(resolvedSection.value()?.embeds)
        XCTAssertTrue(embeds.isEmpty)
    }

    func test_TH1448_TC13_카드내부탭으로외부이동하면_해당카드의clickLog가한건전송되고_외부로열린다() throws {
        // Given
        let logManager = MockLogManager()
        let viewModel = try makeViewModel(threadsRepository: MockThreadsRepository(), logManager: logManager)
        let url = try XCTUnwrap(URL(string: StoreThreadPostFixture.permalinks[0]))
        let clickLog = SDClickLog(screenName: "store_detail", objectType: "card", objectId: "threads_post")
        let routeExpectation = expectation(description: "openURL")
        var openedURL: URL?
        viewModel.output.route.sink { route in
            if case .openURL(let url) = route {
                openedURL = url
                routeExpectation.fulfill()
            }
        }.store(in: &cancellables)

        // When
        viewModel.input.didTapThreadPostLink.send((url: url, clickLog: clickLog))

        // Then
        wait(for: [routeExpectation], timeout: 1)
        XCTAssertEqual(openedURL, url)
        XCTAssertEqual(logManager.sentEvents.count, 1)
        XCTAssertEqual(logManager.sentEvents.first?.name, .click)
        XCTAssertEqual(logManager.sentEvents.first?.parameters[ParameterName.objectId.rawValue] as? String, "threads_post")
    }

    func test_TH1511_TC2_쓰레드와인스타카드가섞이면_인스타는oEmbed요청없이퍼가기코드로_순서대로노출된다() async throws {
        // Given
        let threadsPermalink = StoreThreadPostFixture.permalinks[0]
        let instagramPermalink = StoreThreadPostFixture.instagramPermalink
        let threadsRepository = MockThreadsRepository(htmlsByURL: [threadsPermalink: "<blockquote>threads</blockquote>"])
        let sectionJSON = StoreThreadPostFixture.sectionJSON(cards: [
            StoreThreadPostFixture.cardJSON(permalink: instagramPermalink, platform: "INSTAGRAM"),
            StoreThreadPostFixture.cardJSON(permalink: threadsPermalink, platform: "THREADS")
        ])
        let viewModel = try makeViewModel(threadsRepository: threadsRepository, sectionJSON: sectionJSON)
        let resolvedSection = expectResolvedThreadPostSection(from: viewModel)

        // When
        viewModel.input.load.send(())

        // Then
        await fulfillment(of: [resolvedSection.expectation], timeout: 2)
        let embeds = try XCTUnwrap(resolvedSection.value()?.embeds)
        XCTAssertEqual(embeds.map(\.permalink), [instagramPermalink, threadsPermalink])
        XCTAssertTrue(embeds[0].html.contains("class=\"instagram-media\""))
        XCTAssertTrue(embeds[0].html.contains("data-instgrm-permalink=\"\(instagramPermalink)\""))
        XCTAssertTrue(embeds[0].html.contains("https://platform.instagram.com/en_US/embeds.js"))
        XCTAssertEqual(threadsRepository.requestedURLs, [threadsPermalink])
    }

    func test_TH1511_TC3_platform을모르거나인스타도메인이아닌카드는_노출에서제외된다() async throws {
        // Given
        let threadsPermalink = StoreThreadPostFixture.permalinks[0]
        let threadsRepository = MockThreadsRepository(htmlsByURL: [threadsPermalink: "<blockquote>threads</blockquote>"])
        let sectionJSON = StoreThreadPostFixture.sectionJSON(cards: [
            StoreThreadPostFixture.cardJSON(permalink: "https://www.tiktok.com/@user/video/1", platform: "TIKTOK"),
            StoreThreadPostFixture.cardJSON(permalink: "https://evil.example.com/p/DPinsta01", platform: "INSTAGRAM"),
            StoreThreadPostFixture.cardJSON(permalink: threadsPermalink, platform: "THREADS")
        ])
        let viewModel = try makeViewModel(threadsRepository: threadsRepository, sectionJSON: sectionJSON)
        let resolvedSection = expectResolvedThreadPostSection(from: viewModel)

        // When
        viewModel.input.load.send(())

        // Then
        await fulfillment(of: [resolvedSection.expectation], timeout: 2)
        let embeds = try XCTUnwrap(resolvedSection.value()?.embeds)
        XCTAssertEqual(embeds.map(\.permalink), [threadsPermalink])
        XCTAssertEqual(threadsRepository.requestedURLs, [threadsPermalink])
    }

    private func makeViewModel(
        threadsRepository: MockThreadsRepository,
        logManager: MockLogManager = MockLogManager(),
        sectionJSON: String = StoreThreadPostFixture.threadPostSectionJSON
    ) throws -> StoreSectionsViewModel {
        let json = StoreThreadPostFixture.screenJSON(sections: [sectionJSON])
        let response = try JSONDecoder().decode(StoreScreenV2Response.self, from: Data(json.utf8))
        return StoreSectionsViewModel(
            config: .init(storeId: 12806182, latitude: 37.5, longitude: 127.1),
            dependency: .init(
                storeRepository: MockStoreRepository(fetchStoreScreenV2Result: .success(response)),
                logManager: logManager,
                globalEventBus: MockGlobalEventBus(),
                threadsRepository: threadsRepository
            )
        )
    }

    private func expectResolvedThreadPostSection(
        from viewModel: StoreSectionsViewModel
    ) -> (expectation: XCTestExpectation, value: () -> StoreThreadPostEmbedSection?) {
        let expectation = expectation(description: "resolved thread post section")
        var resolvedSection: StoreThreadPostEmbedSection?
        viewModel.output.sections.sink { sections in
            guard let section = sections.compactMap({ $0 as? StoreThreadPostEmbedSection }).first,
                  section.embeds != nil,
                  resolvedSection == nil else { return }
            resolvedSection = section
            expectation.fulfill()
        }.store(in: &cancellables)
        return (expectation, { resolvedSection })
    }
}
