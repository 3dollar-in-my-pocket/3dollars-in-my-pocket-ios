import Combine

import Common
import Model
import Networking
import Log

final class PollCategoryTabViewModel: BaseViewModel {
    struct Input {
        let firstLoad = PassthroughSubject<Void, Never>()
        let didTapCreatePollButton = PassthroughSubject<Void, Never>()
        let pollCreated = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let categoryName: String
        let screenName: ScreenName = .pollList
        let tabList = CurrentValueSubject<[PollListViewModel], Never>([])
        let createPollButtonTitle = CurrentValueSubject<String?, Never>(nil)
        let isEnabledCreatePollButton = CurrentValueSubject<Bool, Never>(false)
        let showToast = PassthroughSubject<String, Never>()
        let route = PassthroughSubject<Route, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
        let changeTab = PassthroughSubject<Int, Never>()
    }
    
    struct Config {
        let categoryId: String
        let categoryName: String
    }

    struct State {
        var createPolicy: PollCreatePolicyApiResponse?
    }

    enum Route {
        case createPoll(CreatePollModalViewModel)
    }

    let input = Input()
    let output: Output

    private var state = State()
    
    private let config: Config
    private let communityRepository: CommunityRepository
    private let logManager: LogManagerProtocol

    init(
        config: Config,
        communityRepository: CommunityRepository = CommunityRepositoryImpl(),
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.config = config
        self.communityRepository = communityRepository
        self.logManager = logManager
        self.output = Output(categoryName: config.categoryName)

        super.init()

        output.tabList.send(PollListSortType.list.map {
            bindPollListViewModel(with: $0)
        })
    }

    override func bind() {
        super.bind()

        input.firstLoad
            .withUnretained(self)
            .asyncMap { owner, input in
                await owner.communityRepository.fetchUserPollPolicy()
            }
            .withUnretained(self)
            .sink { owner, result in
                switch result {
                case .success(let response):
                    owner.updateCreatePollButton(with: response)
                    owner.state.createPolicy = response.createPolicy
                case .failure(let error):
                    owner.output.showErrorAlert.send(error)
                }
            }
            .store(in: &cancellables)

        input.didTapCreatePollButton
            .withUnretained(self)
            .handleEvents(receiveOutput: { (owner: PollCategoryTabViewModel, _) in
                owner.sendClickCreatePollLog()
            })
            .map { owner, _ in
                .createPoll(owner.bindCreatePollModalViewModel())
            }
            .subscribe(output.route)
            .store(in: &cancellables)

        input.pollCreated
            .withUnretained(self)
            .compactMap { _ in PollListSortType.list.firstIndex(where: { $0 == .latest })}
            .subscribe(output.changeTab)
            .store(in: &cancellables)
    }

    private func updateCreatePollButton(with data: PollPolicyApiResponse) {
        let title = "투표 만들기 \(data.createPolicy.currentCount)/\(data.createPolicy.limitCount)회"
        let isEnabled = data.createPolicy.currentCount < data.createPolicy.limitCount
        output.createPollButtonTitle.send(title)
        output.isEnabledCreatePollButton.send(isEnabled)
    }

    private func bindPollListViewModel(with sortType: PollListSortType) -> PollListViewModel {
        let config = PollListViewModel.Config(
            screenName: output.screenName,
            categoryId: config.categoryId,
            sortType: sortType
        )
        let viewModel = PollListViewModel(config: config)

        input.pollCreated
            .subscribe(viewModel.input.pollCreated)
            .store(in: &cancellables)

        return viewModel
    }

    private func bindCreatePollModalViewModel() -> CreatePollModalViewModel {
        let viewModel = CreatePollModalViewModel(
            pollRetentionDays: state.createPolicy?.pollRetentionDays,
            limitCount: state.createPolicy?.limitCount
        )

        viewModel.output.created
            .subscribe(input.pollCreated)
            .store(in: &cancellables)

        return viewModel
    }
}

// MARK: Log
extension PollCategoryTabViewModel {
    private func sendClickCreatePollLog() {
        logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickCreatePoll
        ))
    }
}
