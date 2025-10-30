import Foundation
import Combine

import FeedInterface
import Common
import Model
import Networking

extension FeedListViewModel {
    struct Input {
        let load = PassthroughSubject<Void, Never>()
        let reload = PassthroughSubject<Void, Never>()
        let willDisplayCell = PassthroughSubject<Int, Never>()
        let didTapFeed = PassthroughSubject<Int, Never>()
    }
    
    struct Output {
        let datasource = CurrentValueSubject<[FeedListSection], Never>([])
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct State {
        var cursor: CursorString? = nil
        var feeds: [FeedResponse] = []
        var mapLatitude: Double?
        var mapLongitude: Double?
        var advertisement: AdvertisementResponse?
    }
    
    enum Route {
        case showErrorAlert(Error)
        case deepLink(SDLink)
    }
}

public final class FeedListViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    private var state: State
    private let dependency: FeedListViewModelDependency
    
    public init(config: FeedListViewModelConfig, dependency: FeedListViewModelDependency = FeedListViewModelDependency()) {
        self.state = State(mapLatitude: config.mapLatitude, mapLongitude: config.mapLongitude)
        self.dependency = dependency
        
        super.init()
    }
    
    public override func bind() {
        input.load
            .withUnretained(self)
            .sink { (owner: FeedListViewModel, _) in
                owner.state.cursor = nil
                owner.fetchAdvertisement()
                owner.loadFeedList()
            }
            .store(in: &cancellables)
        
        input.reload
            .withUnretained(self)
            .sink { (owner: FeedListViewModel, _) in
                owner.state.cursor = nil
                owner.state.feeds = []
                owner.loadFeedList()
            }
            .store(in: &cancellables)
        
        input.willDisplayCell
            .withUnretained(self)
            .sink { (owner: FeedListViewModel, index: Int) in
                guard owner.canLoadMore(index: index) else { return }
                owner.loadFeedList()
            }
            .store(in: &cancellables)
        
        input.didTapFeed
            .withUnretained(self)
            .sink { (owner: FeedListViewModel, index: Int) in
                guard let feed = owner.state.feeds[safe: index - 1] else { return }
                owner.output.route.send(.deepLink(feed.link))
            }
            .store(in: &cancellables)
    }
    
    private func fetchAdvertisement() {
        Task {
            let advertisementResponse = try? await dependency.advertisementRepository.fetchAdvertisements(input: .init(position: .localNewsFeed)).get()
            state.advertisement = advertisementResponse?.advertisements.first
        }
    }
    
    private func loadFeedList() {
        Task {
            let input = FetchFeedInput(
                cursor: state.cursor?.nextCursor,
                mapLatitude: state.mapLatitude,
                mapLongitude: state.mapLongitude
            )
            let result = await dependency.feedRepository.fetchFeed(input: input)
            
            switch result {
            case .success(let response):
                state.cursor = response.cursor
                state.feeds.append(contentsOf: response.contents)
                refreshDatasource()
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
    }
    
    private func refreshDatasource() {
        let advertisementItem = FeedListSectionItem.advertisement(state.advertisement)
        let feedItemList = state.feeds.map { FeedListSectionItem.feed($0) }
        
        output.datasource.send([.init(items: [advertisementItem] + feedItemList)])
    }
    
    private func canLoadMore(index: Int) -> Bool {
        return index >= state.feeds.count
        && state.cursor?.hasMore == true
        && state.cursor?.nextCursor != nil
    }
}
