import Combine

import Common
import Model
import Networking

final class PollCategoryTabViewModel: BaseViewModel {
    struct Input {
        let firstLoad = PassthroughSubject<Void, Never>()
        let didTapCreatePollButton = PassthroughSubject<Void, Never>()
        let updatePollList = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let tabList = CurrentValueSubject<[PollListViewModel], Never>([])
        let createPollButtonTitle = CurrentValueSubject<String?, Never>(nil)
        let isEnabledCreatePollButton = CurrentValueSubject<Bool, Never>(false)
        let showToast = PassthroughSubject<String, Never>()
        let route = PassthroughSubject<Route, Never>()
        let updatePollList = PassthroughSubject<Void, Never>()
    }

    struct State {

    }

    enum Route {
        case createPoll(CreatePollModalViewModel)
    }

    let input = Input()
    let output = Output()

    private var state = State()
    private let communityService: CommunityServiceProtocol

    init(
        communityService: CommunityServiceProtocol = CommunityService()
    ) {
        self.communityService = communityService

        super.init()

        output.tabList.send([
            bindPollListViewModel(),
            bindPollListViewModel()
        ])
    }

    override func bind() {
        super.bind()

        input.firstLoad
            .withUnretained(self)
            .withUnretained(self)
            .asyncMap { owner, input in
                await owner.communityService.fetchUserPollPolicy()
            }
            .withUnretained(self)
            .sink { owner, result in
                switch result {
                case .success(let response):
                    owner.updateCreatePollButton(with: response)
                case .failure(let error):
                    owner.output.showToast.send("유저 투표 정책 조회 실패: \(error.localizedDescription)")
                }
            }
            .store(in: &cancellables)

        input.didTapCreatePollButton
            .withUnretained(self)
            .map { owner, _ in
                .createPoll(owner.bindCreatePollModalViewModel())
            }
            .subscribe(output.route)
            .store(in: &cancellables)
    }

    private func updateCreatePollButton(with data: PollPolicyApiResponse) {
        let title = "투표 만들기 \(data.createPolicy.currentCount)/\(data.createPolicy.limitCount)회"
        let isEnabled = data.createPolicy.currentCount < data.createPolicy.limitCount
        output.createPollButtonTitle.send(title)
        output.isEnabledCreatePollButton.send(isEnabled)
    }

    private func bindPollListViewModel() -> PollListViewModel {
        let viewModel = PollListViewModel()

        output.updatePollList
            .subscribe(viewModel.input.reload)
            .store(in: &cancellables)

        return viewModel
    }

    private func bindCreatePollModalViewModel() -> CreatePollModalViewModel {
        let viewModel = CreatePollModalViewModel()

        viewModel.output.created
            .subscribe(input.updatePollList)
            .store(in: &cancellables)

        return viewModel
    }
}
