import Combine

import Common
import Model
import Networking
import Log

final class PollDetailCommentCellViewModel: BaseViewModel {
    struct Input {
        let didTapReportOrUpdateButton = PassthroughSubject<Void, Never>()
        let deleteAction = PassthroughSubject<Void, Never>()
        let didTapReviewLikeButton = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let screenName: ScreenName
        var item: PollCommentWithUserApiResponse
        let isMine: Bool
        let showLoading = PassthroughSubject<Bool, Never>()
        let showToast = PassthroughSubject<String, Never>()
        let deleteCell = PassthroughSubject<String, Never>()
        let didTapReportButton = PassthroughSubject<String, Never>()
        let showDeleteAlert = PassthroughSubject<Void, Never>()
        let refresh = PassthroughSubject<Void, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
    }

    struct State {

    }
    
    struct Config {
        let screenName: ScreenName
        let pollId: String
        let commentId: String
        let data: PollCommentWithUserApiResponse
    }

    lazy var identifier = ObjectIdentifier(self)

    let input = Input()
    var output: Output
    let config: Config

    private var commentId: String {
        config.data.comment.commentId
    }
    private var state = State()
    private let communityService: CommunityServiceProtocol
    private let logManager: LogManagerProtocol

    init(
        config: Config,
        communityService: CommunityServiceProtocol = CommunityService(),
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.config = config
        self.communityService = communityService
        self.logManager = logManager
        self.output = Output(
            screenName: config.screenName,
            item: config.data,
            isMine: config.data.comment.isOwner
        )

        super.init()
    }

    override func bind() {
        super.bind()

        let didTapReportOrUpdateButton = input.didTapReportOrUpdateButton.share()

        didTapReportOrUpdateButton
            .withUnretained(self)
            .filter { owner, _ in owner.output.isMine }
            .handleEvents(receiveOutput: { (owner: PollDetailCommentCellViewModel, _) in
                owner.sendClickDeleteReviewLog(reviewId: owner.commentId)
            })
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
                    pollId: owner.config.pollId,
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
                owner.sendClickReportReviewLog(reviewId: owner.commentId)
                owner.output.didTapReportButton.send(owner.commentId)
            }
            .store(in: &cancellables)
        
        input.didTapReviewLikeButton
            .withUnretained(self)
            .sink { (owner: PollDetailCommentCellViewModel, _) in
                owner.toggleSticker()
            }
            .store(in: &cancellables)
    }
    
    private func toggleSticker() {
        guard let sticker = output.item.stickers.first else { return }
        
        Task {
            let input = PollCommentStickerListInput(stickers: sticker.reactedByMe ? [] : [.init(stickerId: sticker.stickerId)])
            let result = await communityService.toggleReviewSticker(pollId: config.pollId, commentId: config.commentId, input: input)
            
            switch result {
            case .success(_):
                if output.item.stickers[0].reactedByMe == true {
                    output.item.stickers[0].count -= 1
                } else {
                    output.item.stickers[0].count += 1
                }
                output.item.stickers[0].reactedByMe.toggle()
                output.refresh.send(())
            case .failure(let error):
                output.showErrorAlert.send(error)
            }
        }
    }
}

extension PollDetailCommentCellViewModel {
    private func sendClickReportReviewLog(reviewId: String) {
        logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickReport,
            extraParameters: [
                .reviewId: reviewId
            ]
        ))
    }
    
    private func sendClickDeleteReviewLog(reviewId: String) {
        logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickDeleteReview,
            extraParameters: [
                .reviewId: reviewId
            ]))
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
