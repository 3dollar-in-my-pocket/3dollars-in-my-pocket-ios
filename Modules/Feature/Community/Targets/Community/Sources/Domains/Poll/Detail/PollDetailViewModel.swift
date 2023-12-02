import Foundation
import Combine

import Networking
import Model
import Common
import Log

final class PollDetailViewModel: BaseViewModel {

    enum Constants {
        static let commentSize: Int = 20
    }

    struct Input {
        let firstLoad = PassthroughSubject<Void, Never>()
        let didTapReportButton = PassthroughSubject<Void, Never>()
        let comment = CurrentValueSubject<String, Never>("")
        let didTapWirteCommentButton = PassthroughSubject<Void, Never>()
        let willDisplayCommentCell = PassthroughSubject<Int, Never>()
    }

    struct Output {
        let screenName: ScreenName = .pollDetail
        let dataSource = CurrentValueSubject<[PollDetailSection], Never>([])
        let showLoading = PassthroughSubject<Bool, Never>()
        let showToast = PassthroughSubject<String, Never>()
        let route = PassthroughSubject<Route, Never>()
        let completedWriteComment = PassthroughSubject<Void, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
    }

    struct State {
        var pollDetail = CurrentValueSubject<PollWithMetaApiResponse?, Never>(nil)
        var comments = CurrentValueSubject<[PollCommentWithUserApiResponse], Never>([])
        let loadComments = PassthroughSubject<Void, Never>()
        let loadComment = PassthroughSubject<String, Never>() // commentId
        var nextCursor: String? = nil
        var hasMore: Bool = false
        var commentTotalCount: Int = 0
        var blindedCommentIds: [String] = []
    }

    enum Route {
        case report(ReportPollViewModel)
    }

    let input = Input()
    let output = Output()

    private var state = State()
    private let communityService: CommunityServiceProtocol
    private let logManager: LogManagerProtocol

    private let pollId: String

    init(
        pollId: String,
        communityService: CommunityServiceProtocol = CommunityService(),
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.pollId = pollId
        self.communityService = communityService
        self.logManager = logManager

        super.init()
    }

    override func bind() {
        super.bind()

        input.firstLoad
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.output.showLoading.send(true)
            })
            .asyncMap { owner, input in
                await owner.communityService.fetchPoll(pollId: owner.pollId)
            }
            .withUnretained(self)
            .sink { owner, result in
                owner.output.showLoading.send(false)
                switch result {
                case .success(let response):
                    owner.state.pollDetail.send(response)
                    owner.state.commentTotalCount = response.meta.totalCommentsCount
                    owner.state.loadComments.send()
                case .failure(let error):
                    owner.output.showErrorAlert.send(error)
                }
            }
            .store(in: &cancellables)

        state.loadComments
            .withUnretained(self)
            .asyncMap { owner, _ in
                await owner.communityService.fetchPollComments(
                    pollId: owner.pollId,
                    input: CursorRequestInput(
                        size: Constants.commentSize,
                        cursor: owner.state.nextCursor
                    )
                )
            }
            .withUnretained(self)
            .sink { owner, result in
                switch result {
                case .success(let response):
                    var updatedComments = owner.state.comments.value

                    let comments = response.contents.map { $0.current }
                        .filter { $0.comment.status != .deleted }
                    updatedComments.append(contentsOf: Array(comments))

                    owner.state.comments.send(updatedComments)
                    owner.state.nextCursor = response.cursor.nextCursor
                    owner.state.hasMore = response.cursor.hasMore
                case .failure(let error):
                    owner.output.showErrorAlert.send(error)
                }
            }
            .store(in: &cancellables)

        input.didTapReportButton
            .withUnretained(self)
            .handleEvents(receiveOutput: { (owner: PollDetailViewModel, _) in
                owner.sendClickReportPollLog()
            })
            .map { owner, _ in
                .report(owner.bindReportPollViewModel(pollId: owner.pollId))
            }
            .subscribe(output.route)
            .store(in: &cancellables)

        state.pollDetail
            .combineLatest(state.comments)
            .withUnretained(self)
            .sink { owner, elements in
                let (detail, comments) = elements
                owner.updateDataSource(item: detail, comments: comments)
            }
            .store(in: &cancellables)

        input.didTapWirteCommentButton
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.output.showLoading.send(true)
            })
            .compactMap { owner, _ in
                let comment = owner.input.comment.value
                guard comment.isNotEmpty else { return nil }
                return CreatePollCommentRequestInput(content: comment)
            }
            .withUnretained(self)
            .asyncMap { owner, input in
                await owner.communityService.createPollComment(
                    pollId: owner.pollId,
                    input: input
                )
            }
            .withUnretained(self)
            .sink { owner, result in
                switch result {
                case .success(let response):
                    owner.state.loadComment.send(response.id)
                case .failure(let error):
                    owner.output.showLoading.send(false)
                    owner.output.showErrorAlert.send(error)
                }
            }
            .store(in: &cancellables)

        state.loadComment
            .withUnretained(self)
            .asyncMap { owner, commentId in
                await owner.communityService.fetchPollComment(
                    pollId: owner.pollId,
                    commentId: commentId
                )
            }
            .withUnretained(self)
            .sink { owner, result in
                owner.output.showLoading.send(false)
                switch result {
                case .success(let response):
                    let comments = [response.current] + owner.state.comments.value
                    owner.state.commentTotalCount += 1
                    owner.state.comments.send(comments)
                    owner.output.completedWriteComment.send()
                case .failure(let error):
                    owner.output.showErrorAlert.send(error)
                }
            }
            .store(in: &cancellables)

        input.willDisplayCommentCell
            .withUnretained(self)
            .filter { owner, row in
                owner.canLoadMore(willDisplayRow: row)
            }
            .sink { owner, _ in
                owner.state.loadComments.send()
            }
            .store(in: &cancellables)
    }

    private func updateDataSource(item: PollWithMetaApiResponse?, comments: [PollCommentWithUserApiResponse]) {
        var sections: [PollDetailSection] = []

        if let item {
            sections.append(PollDetailSection(type: .detail, items: [
                .detail(bindPollItemCellViewModel(with: item))
            ]))
        }

        var commentSectionItems: [PollDetailSectionItem] = []

        comments.forEach { item in
            if item.comment.status == .blinded || state.blindedCommentIds.contains(where: { $0 == item.comment.commentId }) {
                commentSectionItems.append(.blindComment(item.comment.commentId))
            } else {
                commentSectionItems.append(.comment(bindCommentCellViewModel(with: item)))
            }
        }

        sections.append(PollDetailSection(
            type: .comment(totalCount: state.commentTotalCount),
            items: commentSectionItems
        ))

        output.dataSource.send(sections)
    }

    private func bindPollItemCellViewModel(with data: PollWithMetaApiResponse) -> PollItemCellViewModel {
        let config = PollItemCellViewModel.Config(screenName: output.screenName, data: data)
        let cellViewModel = PollItemCellViewModel(config: config)
// TODO
//        cellViewModel.output.reloadComments.mapVoid
//            .subscribe(state.loadComments)
//            .store(in: &cancellables)

        cellViewModel.output.showErrorAlert
            .subscribe(output.showErrorAlert)
            .store(in: &cancellables)
        return cellViewModel
    }

    private func bindCommentCellViewModel(with data: PollCommentWithUserApiResponse) -> PollDetailCommentCellViewModel {
        let config = PollDetailCommentCellViewModel.Config(
            screenName: output.screenName,
            pollId: pollId,
            commentId: data.comment.commentId,
            data: data
        )
        let cellViewModel = PollDetailCommentCellViewModel(config: config)

        cellViewModel.output.deleteCell
            .withUnretained(self)
            .sink { owner, commentId in
                var updatedComments = owner.state.comments.value
                updatedComments.removeAll(where: {
                    $0.comment.commentId == commentId
                })
                owner.state.comments.send(updatedComments)
            }
            .store(in: &cancellables)

        cellViewModel.output.didTapReportButton
            .withUnretained(self)
            .map { owner, commentId in
                .report(owner.bindReportPollViewModel(pollId: owner.pollId, commentId: commentId))
            }
            .subscribe(output.route)
            .store(in: &cancellables)

        return cellViewModel
    }

    private func bindReportPollViewModel(pollId: String, commentId: String? = nil) -> ReportPollViewModel {
        let viewModel = ReportPollViewModel(pollId: pollId, commentId: commentId)

        viewModel.output.reportComment
            .withUnretained(self)
            .sink { (owner: PollDetailViewModel, id: String) in
                owner.state.blindedCommentIds.append(id)
                owner.updateDataSource(
                    item: owner.state.pollDetail.value,
                    comments: owner.state.comments.value
                )
            }
            .store(in: &cancellables)

        return viewModel
    }

    private func canLoadMore(willDisplayRow: Int) -> Bool {
        return willDisplayRow == state.comments.value.count - 1 && state.hasMore
    }
}

// MARK: Log
extension PollDetailViewModel {
    private func sendClickReportPollLog() {
        logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickReport,
            extraParameters: [
                .pollId: pollId
            ]
        ))
    }
}
