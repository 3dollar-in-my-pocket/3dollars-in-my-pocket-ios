import Combine

import Common
import Model
import Networking

final class PollDetailCommentCellViewModel: BaseViewModel {
    struct Input {
        let didTapReportOrUpdateButton = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let item: PollCommentWithUserApiResponse
        let isMine: Bool
        let showLoading = PassthroughSubject<Bool, Never>()
        let showToast = PassthroughSubject<String, Never>()
        let deleteCell = PassthroughSubject<String, Never>()
    }

    struct State {

    }

    lazy var identifier = ObjectIdentifier(self)

    let input = Input()
    let output: Output

    private var state = State()
    private let communityService: CommunityServiceProtocol

    private let pollId: String
    private let userInfo: UserWithDeviceApiResponse?

    init(
        pollId: String,
        data: PollCommentWithUserApiResponse,
        userInfo: UserWithDeviceApiResponse?,
        communityService: CommunityServiceProtocol = CommunityService()
    ) {
        self.pollId = pollId
        self.communityService = communityService
        self.userInfo = userInfo
        self.output = Output(
            item: data,
            isMine: userInfo?.userId == data.commentWriter.userId
        )

        super.init()
    }

    override func bind() {
        super.bind()

        let delete = input.didTapReportOrUpdateButton
            .withUnretained(self)
            .filter { owner, _ in owner.output.isMine }

        delete
            .handleEvents(receiveOutput: { owner, _ in
                owner.output.showLoading.send(true)
            })
            .asyncMap { owner, input in
                await owner.communityService.deletePollComment(
                    pollId: owner.pollId,
                    commentId: owner.output.item.comment.commentId
                )
            }
            .withUnretained(self)
            .sink { owner, result in
                owner.output.showLoading.send(false)
                switch result {
                case .success:
                    owner.output.deleteCell.send(owner.output.item.comment.commentId)
                    owner.output.showToast.send("삭제했어요")
                case .failure(let error):
                    owner.output.showToast.send("실패: \(error.localizedDescription)")
                }
            }
            .store(in: &cancellables)
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
