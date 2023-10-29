import Combine
import Foundation

import Common
import Model
import Networking

final class CommunityPollListCellViewModel: BaseViewModel {
    struct Input {
        let didSelectPollItem = PassthroughSubject<Int, Never>()
        let didSelectCategory = PassthroughSubject<Void, Never>()
        let reload = PassthroughSubject<Void, Never>()
        let updateStoredContentOffset = PassthroughSubject<CGPoint?, Never>()
    }

    struct Output {
        let pollList = CurrentValueSubject<[PollItemCellViewModel], Never>([])
        let didSelectPollItem = PassthroughSubject<String, Never>()
        let didSelectCategory = PassthroughSubject<String, Never>()
        let storedContentOffset = CurrentValueSubject<CGPoint?, Never>(nil)
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
                owner.output.didSelectPollItem.send(item.pollId)
            }
            .store(in: &cancellables)

        input.reload
            .withUnretained(self)
            .sink { owner, _ in
                owner.fetchPolls()
            }
            .store(in: &cancellables)

        input.updateStoredContentOffset
            .subscribe(output.storedContentOffset)
            .store(in: &cancellables)
    }

    private func fetchPolls() {
        Task { [weak self] in
            guard let self else { return }

            let result = await communityService.fetchPolls(input: FetchPollsRequestInput(sortType: .popular))

            switch result {
            case .success(let response):
                self.output.pollList.send(response.contents.map {
                    self.bindPollItemCellViewModel(with: $0)
                })
            case .failure(let failure):
                print("💜error: \(failure)")
            }
        }
    }

    private func bindPollItemCellViewModel(with data: PollWithMetaApiResponse) -> PollItemCellViewModel {
        let cellViewModel = PollItemCellViewModel(data: data)
        return cellViewModel
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
