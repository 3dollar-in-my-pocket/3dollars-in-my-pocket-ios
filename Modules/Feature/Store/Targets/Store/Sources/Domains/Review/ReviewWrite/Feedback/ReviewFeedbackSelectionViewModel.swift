import Foundation
import Combine

import Networking
import Model
import Common
import Log

final class ReviewFeedbackSelectionViewModel: BaseViewModel {
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
        var selectedFeedbacks: Set<FeedbackType> = .init()
        let error = PassthroughSubject<Error, Never>()
    }

    enum Route {
        case back
    }

    let input = Input()
    var output: Output

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
            .sink { (owner: ReviewFeedbackSelectionViewModel, sectionItem: BossStoreFeedbackSectionItem) in
                if case .feedback(let item, _) = sectionItem {
                    if owner.output.selectedFeedbacks.contains(item) {
                        owner.output.selectedFeedbacks.remove(item)
                    } else {
                        owner.output.selectedFeedbacks.insert(item)
                    }
                    let items: [BossStoreFeedbackSectionItem] = owner.feedbackTypes.map {
                        .feedback(item: $0, isSelected: owner.output.selectedFeedbacks.contains($0))
                    }
                    owner.output.dataSource.send(items)
                    owner.output.isEnabledButton.send(!owner.output.selectedFeedbacks.isEmpty)
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: Log
extension ReviewFeedbackSelectionViewModel {
    private func sendClickWriteReviewLog() {
        logmanager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickWriteReview,
            extraParameters: [.storeId: storeId]
        ))
    }
}
