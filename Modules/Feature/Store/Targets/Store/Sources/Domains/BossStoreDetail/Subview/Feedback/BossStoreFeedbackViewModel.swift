import Foundation
import Combine

import Networking
import Model
import Common
import Log

final class BossStoreFeedbackViewModel: BaseViewModel {
    struct Input {
        let firstLoad = PassthroughSubject<Void, Never>()
        let didSelectItem = PassthroughSubject<BossStoreFeedbackSectionItem, Never>()
        let didTapSendFeedbackButton = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let screenName: ScreenName = .bossStoreReview
        let dataSource: CurrentValueSubject<[BossStoreFeedbackSectionItem], Never>
        let showLoading = PassthroughSubject<Bool, Never>()
        let isEnabledButton = CurrentValueSubject<Bool, Never>(false)
        let route = PassthroughSubject<Route, Never>()
        let showToast = PassthroughSubject<String, Never>()
        let sendFeedbacks = PassthroughSubject<Void, Never>()
        let error = PassthroughSubject<Error, Never>()
    }

    struct State {
        var selectItems: Set<FeedbackType> = .init()
    }

    enum Route {
        case back
    }

    let input = Input()
    let output: Output

    private var state = State()

    private let storeId: String
    private let feedbackTypes: [FeedbackType]
    private let feedbackRepository: FeedbackRepository
    private let logmanager: LogManagerProtocol

    init(
        storeId: String,
        feedbackTypes: [FeedbackType],
        feedbackRepository: FeedbackRepository = FeedbackRepositoryImpl(),
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.storeId = storeId
        self.feedbackTypes = feedbackTypes
        self.feedbackRepository = feedbackRepository
        self.logmanager = logManager

        self.output = Output(dataSource: .init(feedbackTypes.map { .feedback(item: $0, isSelected: false) }))

        super.init()
    }

    override func bind() {
        super.bind()

        input.didSelectItem
            .removeDuplicates()
            .withUnretained(self)
            .sink { (owner: BossStoreFeedbackViewModel, sectionItem: BossStoreFeedbackSectionItem) in
                if case .feedback(let item, _) = sectionItem {
                    if owner.state.selectItems.contains(item) {
                        owner.state.selectItems.remove(item)
                    } else {
                        owner.state.selectItems.insert(item)
                    }
                    let items: [BossStoreFeedbackSectionItem] = owner.feedbackTypes.map {
                        .feedback(item: $0, isSelected: owner.state.selectItems.contains($0))
                    }
                    owner.output.dataSource.send(items)
                    owner.output.isEnabledButton.send(!owner.state.selectItems.isEmpty)
                }
            }
            .store(in: &cancellables)

        input.didTapSendFeedbackButton
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.output.showLoading.send(true)
            })
            .asyncMap { owner, input in
                await owner.feedbackRepository.sendFeedbacks(
                    targetType: "BOSS_STORE", // TODO
                    targetId: owner.storeId,
                    feedbackTypes: Array(owner.state.selectItems)
                )
            }
            .withUnretained(self)
            .sink { owner, result in
                owner.output.showLoading.send(false)
                owner.sendClickWriteReviewLog()
                switch result {
                case .success(_):
                    owner.output.showToast.send(Strings.BossStoreFeedback.finishToast)
                    owner.output.route.send(.back)
                    owner.output.sendFeedbacks.send()
                case .failure(let error):
                    owner.output.error.send(error)
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: Log
extension BossStoreFeedbackViewModel {
    private func sendClickWriteReviewLog() {
        logmanager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickWriteReview,
            extraParameters: [.storeId: storeId]
        ))
    }
}
