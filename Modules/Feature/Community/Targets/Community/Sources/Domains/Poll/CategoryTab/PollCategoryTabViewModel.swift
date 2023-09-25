import Combine

import Common
import Model
import Networking

final class PollCategoryTabViewModel: BaseViewModel {
    struct Input {
        let firstLoad = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let createPollButtonTitle = CurrentValueSubject<String?, Never>(nil)
        let isEnabledCreatePollButton = CurrentValueSubject<Bool, Never>(false)
        let showToast = PassthroughSubject<String, Never>()
    }

    struct State {

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
    }

    private func updateCreatePollButton(with data: PollPolicyApiResponse) {
        let title = "투표 만들기 \(data.createPolicy.currentCount)/\(data.createPolicy.limitCount)회"
        let isEnabled = data.createPolicy.currentCount < data.createPolicy.limitCount
        output.createPollButtonTitle.send(title)
        output.isEnabledCreatePollButton.send(isEnabled)
    }
}
