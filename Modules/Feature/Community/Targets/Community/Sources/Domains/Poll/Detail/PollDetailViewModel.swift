import Foundation
import Combine

import Networking
import Model
import Common

final class PollDetailViewModel: BaseViewModel {

    struct Input {
        let firstLoad = PassthroughSubject<Void, Never>()
        let didTapReportButton = PassthroughSubject<Void, Never>()
        let comment = CurrentValueSubject<String, Never>("")
        let didTapWirteCommentButton = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let dataSource = CurrentValueSubject<[PollDetailSection], Never>([])
        let showLoading = PassthroughSubject<Bool, Never>()
        let showToast = PassthroughSubject<String, Never>()
        let route = PassthroughSubject<Route, Never>()
    }

    struct State {
        var pollDetail = CurrentValueSubject<PollWithMetaApiResponse?, Never>(nil)
        var comments = CurrentValueSubject<[PollCommentWithUserApiResponse], Never>([])
        let reloadComments = PassthroughSubject<Void, Never>()
    }

    enum Route {
        case report(ReportPollViewModel)
    }

    let input = Input()
    let output = Output()

    private var state = State()
    private let communityService: CommunityServiceProtocol

    private let pollId: String

    init(
        pollId: String,
        communityService: CommunityServiceProtocol = CommunityService()
    ) {
        self.pollId = pollId
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
            .asyncMap { owner, input in
                await owner.communityService.fetchPoll(pollId: owner.pollId)
            }
            .withUnretained(self)
            .sink { owner, result in
                owner.output.showLoading.send(false)
                switch result {
                case .success(let response):
                    owner.state.pollDetail.send(response)
                case .failure(let error):
                    owner.output.showToast.send("실패: \(error.localizedDescription)")
                }
            }
            .store(in: &cancellables)

        input.firstLoad
            .merge(with: state.reloadComments)
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.output.showLoading.send(true)
            })
            .asyncMap { owner, _ in
                await owner.communityService.fetchPollComments(pollId: owner.pollId, input: CursorRequestInput(size: 20, cursor: nil))
            }
            .withUnretained(self)
            .sink { owner, result in
                owner.output.showLoading.send(false)
                switch result {
                case .success(let response):
                    owner.state.comments.send(response.contents.map { $0.current })
                case .failure(let error):
                    owner.output.showToast.send("실패: \(error.localizedDescription)")
                }
            }
            .store(in: &cancellables)

        input.didTapReportButton
            .withUnretained(self)
            .map { owner, _ in
                    .report(ReportPollViewModel(pollId: owner.pollId))
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
                await owner.communityService.createPollComment(pollId: owner.pollId, input: input)
            }
            .withUnretained(self)
            .sink { owner, result in
                owner.output.showLoading.send(false)
                switch result {
                case .success(let response):
                    owner.state.reloadComments.send()
                case .failure(let error):
                    owner.output.showToast.send("실패: \(error.localizedDescription)")
                }
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

        sections.append(PollDetailSection(
            type: .comment(totalCount: comments.count),
            items: comments.map { .comment(bindCommentCellViewModel(with: $0)) }
        ))

        output.dataSource.send(sections)
    }

    private func bindPollItemCellViewModel(with data: PollWithMetaApiResponse) -> PollItemCellViewModel {
        let cellViewModel = PollItemCellViewModel(data: data)
        return cellViewModel
    }

    private func bindCommentCellViewModel(with data: PollCommentWithUserApiResponse) -> PollDetailCommentCellViewModel {
        let cellViewModel = PollDetailCommentCellViewModel(data: data)
        return cellViewModel
    }
}
