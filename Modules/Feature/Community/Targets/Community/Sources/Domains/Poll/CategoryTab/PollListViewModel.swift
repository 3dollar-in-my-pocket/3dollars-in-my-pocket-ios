import Combine

import Common
import Model
import Networking

final class PollListViewModel: BaseViewModel {
    struct Input {
        let firstLoad = PassthroughSubject<Void, Never>()
        let didSelectPollItem = PassthroughSubject<Int, Never>()
    }

    struct Output {
        let dataSource = CurrentValueSubject<[PollListSection], Never>([])
        let showLoading = PassthroughSubject<Bool, Never>()
        let showToast = PassthroughSubject<String, Never>()
        let route = PassthroughSubject<Route, Never>()
    }

    struct State {

    }

    enum Route {
        case pollDetail(PollDetailViewModel)
    }

    let input = Input()
    let output = Output()
    let sortType: String

    private var state = State()
    private let communityService: CommunityServiceProtocol

    init(
        sortType: String = "LATEST", // TODO
        communityService: CommunityServiceProtocol = CommunityService()
    ) {
        self.sortType = sortType
        self.communityService = communityService

        super.init()
    }

    override func bind() {
        super.bind()

        input.firstLoad
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.output.showLoading.send(true)
            })
            .compactMap { owner, _ in
                return FetchPollsRequestInput()
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
                    let sectionItems: [PollListSectionItem] = response.contents.map {
                        .poll(owner.bindPollItemCellViewModel(with: $0))
                    }
                    owner.output.dataSource.send([
                        PollListSection(items: sectionItems)
                    ])
                case .failure(let error):
                    owner.output.showToast.send("실패: \(error.localizedDescription)")
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
    }

    private func bindPollItemCellViewModel(with data: PollWithMetaApiResponse) -> PollItemCellViewModel {
        let cellViewModel = PollItemCellViewModel(data: data)
        return cellViewModel
    }

    private func bindPollDetailViewModel(with pollId: String) -> PollDetailViewModel {
        let viewModel = PollDetailViewModel(pollId: pollId)
        return viewModel
    }
}
