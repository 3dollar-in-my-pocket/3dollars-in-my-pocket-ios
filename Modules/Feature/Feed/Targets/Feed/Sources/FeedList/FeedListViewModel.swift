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
        let feeds = PassthroughSubject<[FeedResponse], Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct State {
        var cursor: CursorString? = nil
        var feeds: [FeedResponse] = []
        var mapLatitude: Double?
        var mapLongitude: Double?
    }
    
    enum Route {
        case showErrorAlert(Error)
        case deepLink(LinkResponse)
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
                guard let feed = owner.state.feeds[safe: index] else { return }
                owner.output.route.send(.deepLink(feed.link))
            }
            .store(in: &cancellables)
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
                output.feeds.send(state.feeds)
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
    }
    
    private func canLoadMore(index: Int) -> Bool {
        return index >= state.feeds.count - 1
        && state.cursor?.hasMore == true
        && state.cursor?.nextCursor != nil
    }
}
