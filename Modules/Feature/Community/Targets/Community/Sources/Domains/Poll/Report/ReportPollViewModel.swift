import Foundation
import Combine

import Networking
import Model
import Common

final class ReportPollViewModel: BaseViewModel {
    struct Input {
        let firstLoad = PassthroughSubject<Void, Never>()
        let didSelectItem = PassthroughSubject<ReportPollSectionItem, Never>()
        let didTapReportButton = PassthroughSubject<Void, Never>()
        let didChangeText = PassthroughSubject<String, Never>()
    }

    struct Output {
        let showLoading = PassthroughSubject<Bool, Never>()
        let dataSource = CurrentValueSubject<[ReportPollSectionItem], Never>([])
        let isEnabledButton = PassthroughSubject<Bool, Never>()
        let route = PassthroughSubject<Route, Never>()
        let showToast = PassthroughSubject<String, Never>()
    }

    struct State {
        var reasons: [PollReportReason] = []
        var reasonDetail: String = ""
        var selectItem: PollReportReason?
    }

    enum Route {
        case back
    }

    let input = Input()
    let output = Output()

    private var state = State()

    private let pollId: String
    private let communityService: CommunityServiceProtocol

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

        input.didTapReportButton
            .withUnretained(self)
            .sink { owner, _ in
                owner.reportPoll()
            }
            .store(in: &cancellables)

        input.didChangeText
            .withUnretained(self)
            .sink { owner, text in
                owner.state.reasonDetail = text
            }
            .store(in: &cancellables)
    }

    private func fetchPollReasons() {
        Task { [weak self] in
            guard let self else { return }

            let apiResult = await communityService.fetchPollReportReasons()

            switch apiResult {
            case .success(let response):
                let sectionItems: [ReportPollSectionItem] = response.reasons.map {
                    .reason(item: $0, isSelected: false)
                }
                self.state.reasons = response.reasons
                self.output.dataSource.send(sectionItems)
            case .failure(let failure):
                self.output.showToast.send(failure.localizedDescription)
            }
        }
    }

    private func reportPoll() {
        Task { [weak self] in
            guard let self, let item = self.state.selectItem else { return }

            if item.hasReasonDetail, self.state.reasonDetail.isEmpty {
                self.output.showToast.send("신고 사유를 입력해 주세요.")
                return
            }

            let apiResult = await communityService.reportPoll(
                pollId: self.pollId,
                input: .init(reason: item.type, reasonDetail: item.hasReasonDetail ? self.state.reasonDetail : nil)
            )

            switch apiResult {
            case .success(let response):
                print("💜error: \(response)")
                self.output.route.send(.back)
            case .failure(let failure):
                self.output.showToast.send(failure.localizedDescription)
            }
        }
    }
}
