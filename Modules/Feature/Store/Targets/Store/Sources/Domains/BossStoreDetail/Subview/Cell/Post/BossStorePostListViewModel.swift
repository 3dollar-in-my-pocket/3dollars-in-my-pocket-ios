import Foundation
import Combine

import Networking
import Model
import Common
import Log

final class BossStorePostListViewModel: BaseViewModel {
    struct Input {
        let loadTrigger = PassthroughSubject<Void, Never>()
        let willDisplayCell = PassthroughSubject<Int, Never>()
    }

    struct Output {
        let showLoading = PassthroughSubject<Bool, Never>()
        let showToast = PassthroughSubject<String, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
        let sectionItems = CurrentValueSubject<[BossStorePostCellViewModel], Never>([])
        let totalCount = CurrentValueSubject<Int, Never>(0)
    }

    struct State {
        var nextCursor: String? = nil
        var hasMore: Bool = false
        let loadMore = PassthroughSubject<Void, Never>()
    }

    let input = Input()
    let output = Output()

    private var state = State()

    private let storeService: StoreServiceProtocol
    private let userDefaults: UserDefaultsUtil
    private let logManager: LogManagerProtocol

    private let storeId: String
    
    init(
        storeId: String,
        storeService: StoreServiceProtocol = StoreService(),
        userDefaults: UserDefaultsUtil = .shared,
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.storeId = storeId
        self.storeService = storeService
        self.userDefaults = userDefaults
        self.logManager = logManager

        super.init()
    }

    override func bind() {
        super.bind()
        
        input.loadTrigger
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.state.nextCursor = nil
                owner.state.hasMore = false
                owner.output.showLoading.send(true)
            })
            .withUnretained(self)
            .asyncMap { owner, _ in
                await owner.storeService.fetchNewPosts(
                    storeId: owner.storeId,
                    cursor: .init(size: 20, cursor: owner.state.nextCursor)
                )
            }
            .sink { [weak self] result in
                guard let self else { return }
                
                output.showLoading.send(false)
                switch result {
                case .success(let response):
                    output.sectionItems.send(response.contents.map {
                        self.bindPostCellViewModel(with: BossStoreDetailRecentPost(response: $0))
                    })
                    state.hasMore = response.cursor.hasMore
                    state.nextCursor = response.cursor.nextCursor
                case .failure(let error):
                    output.showErrorAlert.send(error)
                }
            }
            .store(in: &cancellables)
        
        input.willDisplayCell
            .withUnretained(self)
            .filter { owner, row in
                owner.canLoadMore(willDisplayRow: row)
            }
            .sink { owner, _ in
                owner.state.loadMore.send()
            }
            .store(in: &cancellables)
        
        state.loadMore
            .withUnretained(self)
            .asyncMap { owner, input in
                await owner.storeService.fetchNewPosts(
                    storeId: owner.storeId,
                    cursor: .init(size: 20, cursor: owner.state.nextCursor)
                )
            }
            .withUnretained(self)
            .sink { owner, result in
                switch result {
                case .success(let response):
                    var sectionItems = owner.output.sectionItems.value
                    sectionItems.append(contentsOf: response.contents.map {
                        self.bindPostCellViewModel(with: BossStoreDetailRecentPost(response: $0))
                    })
                    owner.output.sectionItems.send(sectionItems)
                    
                    owner.state.hasMore = response.cursor.hasMore
                    owner.state.nextCursor = response.cursor.nextCursor
                case .failure(let error):
                    owner.output.showErrorAlert.send(error)
                }
            }
            .store(in: &cancellables)
    }
    
    private func canLoadMore(willDisplayRow: Int) -> Bool {
        return willDisplayRow == output.sectionItems.value.count - 1 && state.hasMore
    }
    
    private func bindPostCellViewModel(with post: BossStoreDetailRecentPost) -> BossStorePostCellViewModel {
        let cellViewModel = BossStorePostCellViewModel(config: .init(data: post, source: .postList))
        return cellViewModel
    }
}


// MARK: Log
private extension BossStorePostListViewModel {
   
}
