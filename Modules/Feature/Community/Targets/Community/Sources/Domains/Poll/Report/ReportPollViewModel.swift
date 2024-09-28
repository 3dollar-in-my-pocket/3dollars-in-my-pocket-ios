import Foundation
import Combine

import Networking
import Model
import Common
import Log

final class ReportPollViewModel: BaseViewModel {
    struct Input {
        let firstLoad = PassthroughSubject<Void, Never>()
        let didSelectItem = PassthroughSubject<ReportPollSectionItem, Never>()
        let didTapReportButton = PassthroughSubject<Void, Never>()
        let didChangeText = PassthroughSubject<String, Never>()
    }

    struct Output {
        let screenName: ScreenName
        let showLoading = PassthroughSubject<Bool, Never>()
        let dataSource = CurrentValueSubject<[ReportPollSectionItem], Never>([])
        let isEnabledButton = PassthroughSubject<Bool, Never>()
        let route = PassthroughSubject<Route, Never>()
        let showToast = PassthroughSubject<String, Never>()
        let reportComment = PassthroughSubject<String, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
    }

    struct State {
        var reasons: [PollReportReason] = []
        var reasonDetail: String = ""
        var selectItem: PollReportReason?
    }
    
    struct Config {
        let screenName: ScreenName
        let pollId: String
        let commentId: String?
    }

    enum Route {
        case back
    }

    let input = Input()
    let output: Output
    let config: Config

    private var state = State()
    private let communityRepository: CommunityRepository
    private let logManager: LogManagerProtocol

    init(
        config: Config,
        communityRepository: CommunityRepository = CommunityRepositoryImpl(),
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.config = config
        self.output = Output(screenName: config.screenName)
        self.communityRepository = communityRepository
        self.logManager = logManager

        super.init()
    }

    override func bind() {
        super.bind()

        input.firstLoad
            .withUnretained(self)
            .sink { owner, _ in
                owner.fetchPollReasons()
            }
            .store(in: &cancellables)

        input.didSelectItem
            .removeDuplicates()
            .withUnretained(self)
            .sink { owner, sectionItem in
                if case .reason(let item, _) = sectionItem {
                    var items: [ReportPollSectionItem] = owner.state.reasons.map {
                        .reason(item: $0, isSelected: $0.type == item.type)
                    }
                    if item.hasReasonDetail {
                        items.append(.reasonDetail)
                    }
                    owner.state.selectItem = item
                    owner.output.dataSource.send(items)

                    // TODO: 텍스트 비교
                    owner.output.isEnabledButton.send(true)
                }
            }
            .store(in: &cancellables)

        input.didChangeText
            .withUnretained(self)
            .sink { owner, text in
                owner.state.reasonDetail = text
            }
            .store(in: &cancellables)

        let reportPoll = input.didTapReportButton
            .withUnretained(self)
            .filter { owner, _ in owner.config.commentId == nil }

        reportPoll
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.output.showLoading.send(true)
            })
            .compactMap { owner, _ in
                guard let item = owner.state.selectItem else { return nil }

                if item.hasReasonDetail, owner.state.reasonDetail.isEmpty {
                    owner.output.showToast.send("신고 사유를 입력해 주세요.")
                    return nil
                }
                return PollReportCreateRequestInput(
                    reason: item.type,
                    reasonDetail: owner.state.reasonDetail
                )
            }
            .withUnretained(self)
            .asyncMap { owner, input in
                await owner.communityRepository.reportPoll(pollId: owner.config.pollId, input: input)
            }
            .withUnretained(self)
            .sink { owner, result in
                owner.sendClickReportLog()
                owner.output.showLoading.send(false)
                switch result {
                case .success(let response):
                    owner.output.showToast.send("신고했어요")
                    owner.output.route.send(.back)
                case .failure(let error):
                    owner.output.showErrorAlert.send(error)
                }
            }
            .store(in: &cancellables)

        let reportComment = input.didTapReportButton
            .withUnretained(self)
            .filter { owner, _ in owner.config.commentId != nil }


        reportComment
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.output.showLoading.send(true)
            })
            .compactMap { owner, _ in
                guard let item = owner.state.selectItem else { return nil }

                if item.hasReasonDetail, owner.state.reasonDetail.isEmpty {
                    owner.output.showToast.send("신고 사유를 입력해 주세요.")
                    return nil
                }
                return PollCommentReportCreateRequestInput(
                    reason: item.type,
                    reasonDetail: owner.state.reasonDetail
                )
            }
            .withUnretained(self)
            .asyncMap { owner, input in
                await owner.communityRepository.reportComment(
                    pollId: owner.config.pollId,
                    commentId: owner.config.commentId ?? "",
                    input: input
                )
            }
            .withUnretained(self)
            .sink { owner, result in
                owner.sendClickReportLog()
                owner.output.showLoading.send(false)
                switch result {
                case .success(let response):
                    owner.output.showToast.send("신고했어요")
                    if let commentId = owner.config.commentId {
                        owner.output.reportComment.send(commentId)
                    }
                    owner.output.route.send(.back)
                case .failure(let error):
                    owner.output.showErrorAlert.send(error)
                }
            }
            .store(in: &cancellables)
    }

    private func fetchPollReasons() {
        Task { [weak self] in
            guard let self else { return }
            
            let apiResult = await communityRepository.fetchPollReportReasons(type: self.config.commentId == nil ? .poll : .pollComment)

            switch apiResult {
            case .success(let response):
                let sectionItems: [ReportPollSectionItem] = response.reasons.map {
                    .reason(item: $0, isSelected: false)
                }
                self.state.reasons = response.reasons
                self.output.dataSource.send(sectionItems)
            case .failure(let failure):
                self.output.showErrorAlert.send(failure)
            }
        }
    }
}

extension ReportPollViewModel {
    private func sendClickReportLog() {
        var parameters: [ParameterName: Any] = [.pollId: config.pollId]
        
        if let commentId = config.commentId {
            parameters[.reviewId] = commentId
        }
        logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickReport,
            extraParameters: parameters
        ))
    }
}
