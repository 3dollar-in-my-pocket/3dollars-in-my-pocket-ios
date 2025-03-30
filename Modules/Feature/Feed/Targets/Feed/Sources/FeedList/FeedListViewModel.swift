import Foundation
import Combine

import FeedInterface
import Common
import Model
import Networking

extension FeedListViewModel {
    struct Input {
        let load = PassthroughSubject<Void, Never>()
        let refresh = PassthroughSubject<Void, Never>()
        let willDisplayCell = PassthroughSubject<Int, Never>()
    }
    
    struct Output {
        let didTapFeed = PassthroughSubject<Int, Never>()
        let feeds = PassthroughSubject<[FeedResponse], Never>()
    }
    
    struct State {
        var cursor: String? = nil
        var mapLatitude: Double?
        var mapLongitude: Double?
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
    
    private func bind() {
        input.load
            .withUnretained(self)
            .sink { (owner: FeedListViewModel, _) in
                <#code#>
            }
            .store(in: &cancellables)
    }
    
    private func loadFeedList() {
        Task {
            
        }
    }
    
}
