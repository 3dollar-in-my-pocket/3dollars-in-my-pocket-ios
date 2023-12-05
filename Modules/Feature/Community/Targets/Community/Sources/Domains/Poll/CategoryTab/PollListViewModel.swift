import Combine

import Common
import Model
import Networking
import Log

final class PollListViewModel: BaseViewModel {
    struct Input {
        let firstLoad = PassthroughSubject<Void, Never>()
        let pollCreated = PassthroughSubject<Void, Never>()
        let reload = PassthroughSubject<Void, Never>()
        let didSelectPollItem = PassthroughSubject<Int, Never>()
        let willDisplaytCell = PassthroughSubject<Int, Never>()
    }

    struct Output {
        let dataSource = CurrentValueSubject<[PollListSection], Never>([])
        let showLoading = PassthroughSubject<Bool, Never>()
        let showToast = PassthroughSubject<String, Never>()
        let route = PassthroughSubject<Route, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
        let scrollToTop = PassthroughSubject<Void, Never>()
        /// 특정 투표 아이템이 업데이트됨
        let updatePoll = PassthroughSubject<PollWithMetaApiResponse, Never>()
    }

    struct State {
        var items: [PollItemCellViewModel] = []
        var nextCursor: String? = nil
        var hasMore: Bool = false
        let loadMore = PassthroughSubject<Void, Never>()
    }

    enum Route {
        case pollDetail(PollDetailViewModel)
    }
    
    struct Config {
        let screenName: ScreenName
        let categoryId: String
        let sortType: PollListSortType
    }

    let input = Input()
    let output = Output()
    let config: Config

    private var state = State()
    private let communityService: CommunityServiceProtocol
    private let logManager: LogManagerProtocol

    init(
        config: Config,
        communityService: CommunityServiceProtocol = CommunityService(),
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.config = config
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
                owner.output.showLoading.send(true)
            })
            .compactMap { owner, _ in
                return FetchPollsRequestInput(
                    categoryId: owner.config.categoryId,
                    sortType: owner.config.sortType,
                    cursor: owner.state.nextCursor
                )
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
                    owner.state.items = response.contents.map { owner.bindPollItemCellViewModel(with: $0) }
                    owner.state.hasMore = response.cursor.hasMore
                    owner.state.nextCursor = response.cursor.nextCursor
                    owner.updateDataSource()
                case .failure(let error):
                    owner.output.showErrorAlert.send(error)
                }
            }
            .store(in: &cancellables)

        input.didSelectPollItem
            .withUnretained(self)
            .compactMap { (owner: PollListViewModel, index: Int) in
                if case .poll(let cellViewModel) = owner.output.dataSource.value.first?.items[safe: index] {
                    return cellViewModel.pollId
                }
                return nil
            }
            .withUnretained(self)
            .handleEvents(receiveOutput: { (owner: PollListViewModel, pollId: String) in
                owner.sendClickPollLog(pollId: pollId)
            })
            .map { owner, pollId in
                    .pollDetail(owner.bindPollDetailViewModel(with: pollId))
            }
            .subscribe(output.route)
            .store(in: &cancellables)

        input.willDisplaytCell
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
                return FetchPollsRequestInput(
                    categoryId: owner.config.categoryId,
                    sortType: owner.config.sortType,
                    cursor: owner.state.nextCursor
                )
            }
            .withUnretained(self)
            .asyncMap { owner, input in
                await owner.communityService.fetchPolls(input: input)
            }
            .withUnretained(self)
            .sink { owner, result in
                switch result {
                case .success(let response):
                    owner.state.items.append(contentsOf: response.contents.map { owner.bindPollItemCellViewModel(with: $0) })
                    owner.state.hasMore = response.cursor.hasMore
                    owner.state.nextCursor = response.cursor.nextCursor
                    owner.updateDataSource()
                case .failure(let error):
                    owner.output.showErrorAlert.send(error)
                }
            }
            .store(in: &cancellables)
        
        input.pollCreated
            .withUnretained(self)
            .filter { owner, _ in owner.config.sortType == .latest }
            .sink { owner, _ in
                owner.input.reload.send()
                owner.output.scrollToTop.send()
            }
            .store(in: &cancellables)
    }

    private func updateDataSource() {
        let sectionItems: [PollListSectionItem] = state.items.map {
            .poll($0)
        }
        output.dataSource.send([
            PollListSection(items: sectionItems)
        ])
    }

    private func bindPollItemCellViewModel(with data: PollWithMetaApiResponse) -> PollItemCellViewModel {
        let config = PollItemCellViewModel.Config(screenName: config.screenName, data: data)
        let cellViewModel = PollItemCellViewModel(config: config)
        output.updatePoll
            .filter { $0.poll.pollId == cellViewModel.pollId }
            .subscribe(cellViewModel.output.item)
            .store(in: &cancellables)
        
        return cellViewModel
    }

    private func bindPollDetailViewModel(with pollId: String) -> PollDetailViewModel {
        let viewModel = PollDetailViewModel(pollId: pollId)
        viewModel.output.updatePoll
            .subscribe(output.updatePoll)
            .store(in: &cancellables)
        return viewModel
    }

    private func canLoadMore(willDisplayRow: Int) -> Bool {
        return willDisplayRow == state.items.count - 1 && state.hasMore
    }
}

// MARK: Log
extension PollListViewModel {
    private func sendClickPollLog(pollId: String) {
        logManager.sendEvent(.init(
            screen: config.screenName,
            eventName: .clickPoll,
            extraParameters: [.pollId: pollId]
        ))
    }
}
