import Foundation
import Combine

import FeedInterface
import Common
import Model
import Networking
import Log

extension FeedListViewModel {
    struct Input {
        let load = PassthroughSubject<(latitude: Double, longitude: Double), Never>()
        let retry = PassthroughSubject<Void, Never>()
        let willDisplayCell = PassthroughSubject<Int, Never>()
        let didTapFeed = PassthroughSubject<FeedResponse, Never>()
    }

    struct Output {
        let screenName: ScreenName = .feedList
        let datasource = CurrentValueSubject<[FeedListSection], Never>([])
        let scrollToTop = PassthroughSubject<Void, Never>()
        let route = PassthroughSubject<Route, Never>()
    }

    enum ContentState: Equatable {
        case loading
        case loaded
        case failed
    }

    struct State {
        var cursor: CursorString?
        var feeds: [FeedResponse] = []
        var mapLatitude: Double?
        var mapLongitude: Double?
        var advertisement: AdvertisementResponse?
        var hasFetchedAdvertisement = false
        var contentState: ContentState = .loading
        var isLoadingMore = false
    }

    enum Route {
        case deepLink(SDLink)
    }
}

public final class FeedListViewModel: BaseViewModel {
    static let skeletonCount = 3
    static let advertisementIndex = 1

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
            .sink { (owner: FeedListViewModel, location) in
                owner.state.mapLatitude = location.latitude
                owner.state.mapLongitude = location.longitude
                owner.fetchAdvertisementIfNeeded()
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
                guard owner.canLoadMore(index: index) else { return }
                owner.loadNextPage()
            }
            .store(in: &cancellables)

        input.didTapFeed
            .withUnretained(self)
            .sink { (owner: FeedListViewModel, feed: FeedResponse) in
                owner.output.route.send(.deepLink(feed.link))
            }
            .store(in: &cancellables)
    }

    private func fetchAdvertisementIfNeeded() {
        guard state.hasFetchedAdvertisement.isNot else { return }
        state.hasFetchedAdvertisement = true

        Task { @MainActor [weak self] in
            guard let self else { return }
            let response = try? await dependency.advertisementRepository.fetchAdvertisements(input: .init(position: .localNewsFeed)).get()
            state.advertisement = response?.advertisements.first
            refreshDatasource()
        }
    }

    private func loadFirstPage() {
        state.cursor = nil
        state.feeds = []
        state.isLoadingMore = false
        state.contentState = .loading
        refreshDatasource()

        let input = makeFetchInput(cursor: nil)
        loadTask?.cancel()
        loadTask = Task { @MainActor [weak self] in
            guard let self else { return }
            let result = await dependency.feedRepository.fetchFeed(input: input)
            guard Task.isCancelled.isNot else { return }

            switch result {
            case .success(let response):
                state.cursor = response.cursor
                state.feeds = response.contents
                state.contentState = .loaded
            case .failure:
                state.contentState = .failed
            }
            refreshDatasource()
        }
    }

    private func loadNextPage() {
        state.isLoadingMore = true
        let input = makeFetchInput(cursor: state.cursor?.nextCursor)

        loadTask = Task { @MainActor [weak self] in
            guard let self else { return }
            let result = await dependency.feedRepository.fetchFeed(input: input)
            guard Task.isCancelled.isNot else { return }
            state.isLoadingMore = false

            guard case .success(let response) = result else { return }
            let loadedIds = Set(state.feeds.map(\.feedId))
            state.cursor = response.cursor
            state.feeds.append(contentsOf: response.contents.filter { loadedIds.contains($0.feedId).isNot })
            refreshDatasource()
        }
    }

    private func makeFetchInput(cursor: String?) -> FetchFeedInput {
        return FetchFeedInput(
            cursor: cursor,
            mapLatitude: state.mapLatitude,
            mapLongitude: state.mapLongitude
        )
    }

    private func refreshDatasource() {
        var contentItems: [FeedListSectionItem]

        switch state.contentState {
        case .loading:
            contentItems = (0..<Self.skeletonCount).map { FeedListSectionItem.skeleton($0) }
        case .failed:
            contentItems = [.error]
        case .loaded where state.feeds.isEmpty:
            contentItems = [.empty]
        case .loaded:
            contentItems = state.feeds.map { FeedListSectionItem.feed($0) }
        }

        contentItems.insert(.advertisement(state.advertisement), at: min(Self.advertisementIndex, contentItems.count))
        output.datasource.send([.init(items: [.header] + contentItems)])
    }

    private func canLoadMore(index: Int) -> Bool {
        let itemCount = output.datasource.value.first?.items.count ?? 0
        return index >= itemCount - 1
        && state.contentState == .loaded
        && state.isLoadingMore.isNot
        && state.cursor?.hasMore == true
        && state.cursor?.nextCursor != nil
    }
}
