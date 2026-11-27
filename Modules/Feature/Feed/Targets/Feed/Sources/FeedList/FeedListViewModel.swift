import Foundation
import Combine

import FeedInterface
import Common
import Model
import Networking
import Log

extension FeedListViewModel {
    struct Input {
        let load = PassthroughSubject<LoadRequest, Never>()
        let retry = PassthroughSubject<Void, Never>()
        let willDisplayCell = PassthroughSubject<Int, Never>()
        let didTapCard = PassthroughSubject<String, Never>()
        let didTapImage = PassthroughSubject<ImageTap, Never>()
        let didTapAdmob = PassthroughSubject<String, Never>()
    }

    struct LoadRequest: Equatable {
        let newsTabId: String
        let latitude: Double
        let longitude: Double
        let maxDistanceM: Double?
    }

    struct ImageTap {
        let cardId: String
        let blockIndex: Int
        let imageIndex: Int
    }

    struct Output {
        let screenName: ScreenName = .feedList
        let datasource = CurrentValueSubject<[FeedListSection], Never>([])
        let scrollToTop = PassthroughSubject<Void, Never>()
        let sectionImpressionLog = PassthroughSubject<SDImpressionLog, Never>()
        let route = PassthroughSubject<Route, Never>()
    }

    enum ContentState: Equatable {
        case loading
        case loaded
        case failed
    }

    struct State {
        var request: LoadRequest?
        var header: SDHeader?
        var items: [HomeNewsItem] = []
        var cursor = HomeNewsCursor()
        var contentState: ContentState = .loading
        var isLoadingMore = false
        var impressedCardIds: Set<String> = []
    }

    enum Route {
        case deepLink(SDLink)
        case presentPhotoViewer(imageUrls: [String], selectedIndex: Int)
    }
}

public final class FeedListViewModel: BaseViewModel {
    static let skeletonCount = 3

    let input = Input()
    let output = Output()
    private var state = State()
    private let dependency: FeedListViewModelDependency
    private var loadTask: Task<Void, Never>?

    public init(dependency: FeedListViewModelDependency = FeedListViewModelDependency()) {
        self.dependency = dependency

        super.init()
    }

    public override func bind() {
        input.load
            .withUnretained(self)
            .sink { (owner: FeedListViewModel, request: LoadRequest) in
                owner.state.request = request
                owner.loadFirstPage()
                owner.output.scrollToTop.send(())
            }
            .store(in: &cancellables)

        input.retry
            .withUnretained(self)
            .sink { (owner: FeedListViewModel, _) in
                owner.loadFirstPage()
            }
            .store(in: &cancellables)

        input.willDisplayCell
            .withUnretained(self)
            .sink { (owner: FeedListViewModel, index: Int) in
                owner.sendImpressionLogIfNeeded(at: index)
                guard owner.canLoadMore(index: index) else { return }
                owner.loadNextPage()
            }
            .store(in: &cancellables)

        input.didTapCard
            .withUnretained(self)
            .sink { (owner: FeedListViewModel, cardId: String) in
                owner.handleCardTap(cardId: cardId)
            }
            .store(in: &cancellables)

        input.didTapImage
            .withUnretained(self)
            .sink { (owner: FeedListViewModel, tap: ImageTap) in
                owner.handleImageTap(tap)
            }
            .store(in: &cancellables)

        input.didTapAdmob
            .withUnretained(self)
            .sink { (owner: FeedListViewModel, cardId: String) in
                guard case .admobCard(let admob) = owner.item(cardId: cardId) else { return }
                owner.dependency.logManager.sendEvent(event: ClickEvent(clickLog: admob.clickLog))
            }
            .store(in: &cancellables)
    }

    private func loadFirstPage() {
        guard let request = state.request else { return }
        state.items = []
        state.cursor = HomeNewsCursor()
        state.impressedCardIds = []
        state.isLoadingMore = false
        state.contentState = .loading
        refreshDatasource()

        loadTask?.cancel()
        loadTask = Task { @MainActor [weak self] in
            guard let self else { return }
            let result = await fetchSection(request: request, cursor: nil)
            guard Task.isCancelled.isNot else { return }

            switch result {
            case .success(let response):
                state.header = response.header ?? state.header
                state.items = uniqueItems(response.items)
                state.cursor = response.cursor
                state.contentState = .loaded
                if let impressionLog = response.impressionLog {
                    output.sectionImpressionLog.send(impressionLog)
                }
            case .failure:
                state.contentState = .failed
            }
            refreshDatasource()
        }
    }

    private func loadNextPage() {
        guard let request = state.request else { return }
        state.isLoadingMore = true
        let cursor = state.cursor.nextCursor

        loadTask = Task { @MainActor [weak self] in
            guard let self else { return }
            let result = await fetchSection(request: request, cursor: cursor)
            guard Task.isCancelled.isNot else { return }
            state.isLoadingMore = false

            guard case .success(let response) = result else { return }
            state.cursor = response.cursor
            state.items = uniqueItems(state.items + response.items)
            refreshDatasource()
        }
    }

    private func fetchSection(request: LoadRequest, cursor: String?) async -> Result<HomeNewsSectionResponse, Error> {
        let input = FetchHomeNewsSectionInput(
            mapLatitude: request.latitude,
            mapLongitude: request.longitude,
            maxDistanceM: request.maxDistanceM,
            cursor: cursor
        )
        return await dependency.screenRepository.fetchHomeNewsSection(newsTabId: request.newsTabId, input: input)
    }

    private func uniqueItems(_ items: [HomeNewsItem]) -> [HomeNewsItem] {
        var seenIds = Set<String>()
        return items.filter { seenIds.insert($0.cardId).inserted }
    }

    private func refreshDatasource() {
        var items: [FeedListSectionItem] = state.header.map { [.header($0)] } ?? []

        switch state.contentState {
        case .loading:
            items += (0..<Self.skeletonCount).map { FeedListSectionItem.skeleton($0) }
        case .failed:
            items.append(.error)
        case .loaded where state.items.isEmpty:
            items.append(.empty)
        case .loaded:
            items += state.items.map { item in
                switch item {
                case .contentCard(let card):
                    return .contentCard(card)
                case .admobCard(let admob):
                    return .admobCard(admob)
                }
            }
        }

        output.datasource.send([.init(items: items)])
    }

    private func canLoadMore(index: Int) -> Bool {
        let itemCount = output.datasource.value.first?.items.count ?? 0
        return index >= itemCount - 1
        && state.contentState == .loaded
        && state.isLoadingMore.isNot
        && state.cursor.hasMore
        && state.cursor.nextCursor != nil
    }

    private func item(cardId: String) -> HomeNewsItem? {
        state.items.first { $0.cardId == cardId }
    }

    private func handleCardTap(cardId: String) {
        guard case .contentCard(let card) = item(cardId: cardId) else { return }
        if let clickLog = card.clickLog {
            dependency.logManager.sendEvent(event: ClickEvent(clickLog: clickLog))
        }
        if let link = card.link {
            output.route.send(.deepLink(link))
        }
    }

    private func handleImageTap(_ tap: ImageTap) {
        guard case .contentCard(let card) = item(cardId: tap.cardId),
              let block = card.bodyBlocks[safe: tap.blockIndex],
              block.images.indices.contains(tap.imageIndex) else { return }
        output.route.send(.presentPhotoViewer(imageUrls: block.images.map(\.url), selectedIndex: tap.imageIndex))
    }

    private func sendImpressionLogIfNeeded(at index: Int) {
        guard let cardId = output.datasource.value.first?.items[safe: index]?.cardId,
              let impressionLog = item(cardId: cardId)?.impressionLog,
              state.impressedCardIds.insert(cardId).inserted else { return }
        dependency.logManager.sendEvent(event: ImpressionEvent(impressionLog: impressionLog))
    }
}
