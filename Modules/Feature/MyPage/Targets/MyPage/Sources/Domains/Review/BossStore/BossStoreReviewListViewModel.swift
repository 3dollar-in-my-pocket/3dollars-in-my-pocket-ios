import Combine

import Common
import Model
import Networking
import Log

final class BossStoreReviewListViewModel: BaseViewModel {
    struct Input {
        let firstLoad = PassthroughSubject<Void, Never>()
        let reload = PassthroughSubject<Void, Never>()
        let willDisplayCell = PassthroughSubject<Int, Never>()
    }

    struct Output {
        let dataSource = CurrentValueSubject<[BossStoreReviewListSection], Never>([])
        let showLoading = PassthroughSubject<Bool, Never>()
        let showToast = PassthroughSubject<String, Never>()
        let route = PassthroughSubject<Route, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
    }

    struct State {
        var nextCursor: String? = nil
        var hasMore: Bool = false
        let loadMore = PassthroughSubject<Void, Never>()
    }

    enum Route {
        case none
    }

    let input = Input()
    let output = Output()

    private var state = State()
    private let communityService: CommunityServiceProtocol
    private let logManager: LogManagerProtocol

    init(
        communityService: CommunityServiceProtocol = CommunityService(),
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.communityService = communityService
        self.logManager = logManager

        super.init()
    }

    override func bind() {
        super.bind()

        input.firstLoad
            .merge(with: input.reload)
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.state.nextCursor = nil
                owner.state.hasMore = false
//                owner.output.showLoading.send(true)
            })
            .compactMap { owner, _ in
                return nil
            }
            .withUnretained(self)
            .asyncMap { owner, input in
                await owner.communityService.fetchPolls(input: input)
            }
            .withUnretained(self)
            .sink { owner, result in
                owner.output.showLoading.send(false)
                switch result {
                case .success(let response):
//                    owner.state.items = response.contents.map { owner.bindPollItemCellViewModel(with: $0) }
                    owner.state.hasMore = response.cursor.hasMore
                    owner.state.nextCursor = response.cursor.nextCursor
                    owner.updateDataSource()
                case .failure(let error):
                    owner.output.showErrorAlert.send(error)
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
            .compactMap { owner, _ in
                return nil
            }
            .withUnretained(self)
            .asyncMap { owner, input in
                await owner.communityService.fetchPolls(input: input)
            }
            .withUnretained(self)
            .sink { owner, result in
                switch result {
                case .success(let response):
//                    owner.state.items.append(contentsOf: response.contents.map { owner.bindPollItemCellViewModel(with: $0) })
                    owner.state.hasMore = response.cursor.hasMore
                    owner.state.nextCursor = response.cursor.nextCursor
                    owner.updateDataSource()
                case .failure(let error):
                    owner.output.showErrorAlert.send(error)
                }
            }
            .store(in: &cancellables)
    }

    private func updateDataSource() {
        
    }

    private func canLoadMore(willDisplayRow: Int) -> Bool {
        //        return willDisplayRow == state.items.count - 1 && state.hasMore
            return false
    }
}
