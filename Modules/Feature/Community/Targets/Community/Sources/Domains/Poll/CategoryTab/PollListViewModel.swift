import Combine

import Common
import Model
import Networking
import Log

final class PollListViewModel: BaseViewModel {
    struct Input {
        let firstLoad = PassthroughSubject<Void, Never>()
        let reload = PassthroughSubject<Void, Never>()
        let didSelectPollItem = PassthroughSubject<Int, Never>()
        let willDisplaytCell = PassthroughSubject<Int, Never>()
    }

    struct Output {
        let screenName: ScreenName = .pollList
        let dataSource = CurrentValueSubject<[PollListSection], Never>([])
        let showLoading = PassthroughSubject<Bool, Never>()
        let showToast = PassthroughSubject<String, Never>()
        let route = PassthroughSubject<Route, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
    }

    struct State {
        var items: [PollWithMetaApiResponse] = []
        var nextCursor: String? = nil
        var hasMore: Bool = false
        let loadMore = PassthroughSubject<Void, Never>()
    }

    enum Route {
        case pollDetail(PollDetailViewModel)
    }

    let input = Input()
    let output = Output()
    let sortType: PollListSortType

    private var state = State()
    private let communityService: CommunityServiceProtocol

    init(
        sortType: PollListSortType = .latest, // 현재 따로 변경하고 있지는 않음
        communityService: CommunityServiceProtocol = CommunityService()
    ) {
        self.sortType = sortType
        self.communityService = communityService

        super.init()
    }

    override func bind() {
        super.bind()

        input.firstLoad
            .merge(with: input.reload)
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.output.showLoading.send(true)
            })
            .compactMap { owner, _ in
                return FetchPollsRequestInput(cursor: owner.state.nextCursor)
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
                    owner.state.items.append(contentsOf: response.contents)
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
                return FetchPollsRequestInput(cursor: owner.state.nextCursor)
            }
            .withUnretained(self)
            .asyncMap { owner, input in
                await owner.communityService.fetchPolls(input: input)
            }
            .withUnretained(self)
            .sink { owner, result in
                switch result {
                case .success(let response):
                    owner.state.items.append(contentsOf: response.contents)
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
        let sectionItems: [PollListSectionItem] = state.items.map {
            .poll(bindPollItemCellViewModel(with: $0))
        }
        output.dataSource.send([
            PollListSection(items: sectionItems)
        ])
    }

    private func bindPollItemCellViewModel(with data: PollWithMetaApiResponse) -> PollItemCellViewModel {
        let config = PollItemCellViewModel.Config(screenName: output.screenName, data: data)
        let cellViewModel = PollItemCellViewModel(config: config)
        return cellViewModel
    }

    private func bindPollDetailViewModel(with pollId: String) -> PollDetailViewModel {
        let viewModel = PollDetailViewModel(pollId: pollId)
        return viewModel
    }

    private func canLoadMore(willDisplayRow: Int) -> Bool {
        return willDisplayRow == state.items.count - 1 && state.hasMore
    }
}
