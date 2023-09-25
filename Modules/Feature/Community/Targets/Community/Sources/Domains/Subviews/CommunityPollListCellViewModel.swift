import Combine

import Common
import Model
import Networking

final class CommunityPollListCellViewModel: BaseViewModel {
    struct Input {
        let didSelectPollItem = PassthroughSubject<Int, Never>()
        let didSelectCategory = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let pollList = CurrentValueSubject<[PollWithMetaApiResponse], Never>([])
        let didSelectPollItem = PassthroughSubject<String, Never>()
        let didSelectCategory = PassthroughSubject<String, Never>()
    }

    struct State {
    }

    lazy var identifier = ObjectIdentifier(self)

    let input = Input()
    let output: Output

    private var state = State()

    private let communityService: CommunityServiceProtocol

    init(
        communityService: CommunityServiceProtocol = CommunityService()
    ) {
        self.communityService = communityService
        self.output = Output()

        super.init()

        fetchPolls()
    }

    override func bind() {
        super.bind()

        input.didSelectCategory
            .map { "TASTE_VS_TASTE" }
            .subscribe(output.didSelectCategory)
            .store(in: &cancellables)

        input.didSelectPollItem
            .withUnretained(self)
            .sink { owner, index in
                guard let item = owner.output.pollList.value[safe: index] else { return }
                owner.output.didSelectPollItem.send(item.poll.pollId)
            }
            .store(in: &cancellables)
    }

    private func fetchPolls() {
        Task { [weak self] in
            guard let self else { return }

            let input = FetchPollsRequestInput()

            let result = await communityService.fetchPolls(input: input)

            switch result {
            case .success(let response):
                self.output.pollList.send(response.contents)
            case .failure(let failure):
                print("💜error: \(failure)")
            }
        }
    }
}

extension CommunityPollListCellViewModel: Hashable {
    static func == (lhs: CommunityPollListCellViewModel, rhs: CommunityPollListCellViewModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
