import Combine

import Common
import Model
import Networking

final class PollDetailCommentCellViewModel: BaseViewModel {
    struct Input {

    }

    struct Output {
        let item: CurrentValueSubject<PollCommentWithUserApiResponse, Never>
        let showLoading = PassthroughSubject<Bool, Never>()
        let showToast = PassthroughSubject<String, Never>()
    }

    struct State {

    }

    lazy var identifier = ObjectIdentifier(self)

    let input = Input()
    let output: Output

    private var state = State()
    private let communityService: CommunityServiceProtocol

    init(
        data: PollCommentWithUserApiResponse,
        communityService: CommunityServiceProtocol = CommunityService()
    ) {
        self.communityService = communityService
        self.output = Output(
            item: .init(data)
        )

        super.init()
    }

    override func bind() {
        super.bind()

    }
}

extension PollDetailCommentCellViewModel: Hashable {
    static func == (lhs: PollDetailCommentCellViewModel, rhs: PollDetailCommentCellViewModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
