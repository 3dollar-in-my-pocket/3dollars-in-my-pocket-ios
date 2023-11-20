import Combine

import Common
import Model
import Networking

final class PollItemCellViewModel: BaseViewModel {
    struct Input {
        let didSelectFirstOption = PassthroughSubject<Void, Never>()
        let didSelectSecondOption = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let item: CurrentValueSubject<PollWithMetaApiResponse, Never>
        let showLoading = PassthroughSubject<Bool, Never>()
        let showToast = PassthroughSubject<String, Never>()
        let reloadComments = PassthroughSubject<Int, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
    }

    struct State {
        let reload = PassthroughSubject<Void, Never>()
    }

    lazy var identifier = ObjectIdentifier(self)

    let input = Input()
    let output: Output
    let pollId: String

    private var state = State()
    private let communityService: CommunityServiceProtocol

    init(
        data: PollWithMetaApiResponse,
        communityService: CommunityServiceProtocol = CommunityService()
    ) {
        self.pollId = data.poll.pollId
        self.communityService = communityService
        self.output = Output(
            item: .init(data)
        )

        super.init()
    }

    override func bind() {
        super.bind()

        input.didSelectFirstOption.map { _ in 0 }
            .merge(with: input.didSelectSecondOption.map { _ in 1 })
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.output.showLoading.send(true)
            })
            .compactMap { owner, optionIndex in
                guard let optionId = owner.output.item.value.poll.options[safe: optionIndex]?.optionId else { return nil }
                return PollChoiceCreateRequestInput(options: [.init(optionId: optionId)])
            }
            .withUnretained(self)
            .asyncMap { owner, input in
                await owner.communityService.createChoicePoll(pollId: owner.pollId, input: input)
            }
            .withUnretained(self)
            .sink { owner, result in
                switch result {
                case .success(let response):
                    owner.state.reload.send()
                case .failure(let error):
                    owner.output.showErrorAlert.send(error)
                    owner.output.showLoading.send(false)
                }
            }
            .store(in: &cancellables)

        state.reload
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.output.showLoading.send(true)
            })
            .asyncMap { owner, _ in
                await owner.communityService.fetchPoll(pollId: owner.pollId)
            }
            .withUnretained(self)
            .sink { owner, result in
                owner.output.showLoading.send(false)

                switch result {
                case .success(let response):
                    owner.output.item.send(response)
                    owner.output.reloadComments.send(response.meta.totalCommentsCount)
                case .failure(let error):
                    owner.output.showErrorAlert.send(error)
                }
            }
            .store(in: &cancellables)

    }
}

extension PollItemCellViewModel: Hashable {
    static func == (lhs: PollItemCellViewModel, rhs: PollItemCellViewModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
