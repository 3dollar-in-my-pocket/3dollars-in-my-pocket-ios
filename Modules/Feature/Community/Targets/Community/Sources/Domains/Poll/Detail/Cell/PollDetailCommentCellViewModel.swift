import Combine

import Common
import Model
import Networking

final class PollDetailCommentCellViewModel: BaseViewModel {
    struct Input {
        let didTapReportOrUpdateButton = PassthroughSubject<Void, Never>()
        let deleteAction = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let item: PollCommentWithUserApiResponse
        let isMine: Bool
        let showLoading = PassthroughSubject<Bool, Never>()
        let showToast = PassthroughSubject<String, Never>()
        let deleteCell = PassthroughSubject<String, Never>()
        let didTapReportButton = PassthroughSubject<String, Never>()
        let showDeleteAlert = PassthroughSubject<Void, Never>()
    }

    struct State {

    }

    lazy var identifier = ObjectIdentifier(self)

    let input = Input()
    let output: Output

    private var state = State()
    private let communityService: CommunityServiceProtocol

    private let pollId: String
    private let commentId: String

    init(
        pollId: String,
        data: PollCommentWithUserApiResponse,
        communityService: CommunityServiceProtocol = CommunityService()
    ) {
        self.pollId = pollId
        self.commentId = data.comment.commentId
        self.communityService = communityService
        self.output = Output(
            item: data,
            isMine: data.comment.isOwner
        )

        super.init()
    }

    override func bind() {
        super.bind()

        let didTapReportOrUpdateButton = input.didTapReportOrUpdateButton.share()

        didTapReportOrUpdateButton
            .withUnretained(self)
            .filter { owner, _ in owner.output.isMine }
            .mapVoid
            .subscribe(output.showDeleteAlert)
            .store(in: &cancellables)

        input.deleteAction
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.output.showLoading.send(true)
            })
            .asyncMap { owner, input in
                await owner.communityService.deletePollComment(
                    pollId: owner.pollId,
                    commentId: owner.commentId
                )
            }
            .withUnretained(self)
            .sink { owner, result in
                owner.output.showLoading.send(false)
                switch result {
                case .success:
                    owner.output.deleteCell.send(owner.commentId)
                    owner.output.showToast.send("삭제했어요")
                case .failure(let error):
                    owner.output.showToast.send("실패: \(error.localizedDescription)")
                }
            }
            .store(in: &cancellables)

        let report = didTapReportOrUpdateButton
            .withUnretained(self)
            .filter { owner, _ in !owner.output.isMine }

        report
            .withUnretained(self)
            .sink { owner, _ in
                owner.output.didTapReportButton.send(owner.commentId)
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
