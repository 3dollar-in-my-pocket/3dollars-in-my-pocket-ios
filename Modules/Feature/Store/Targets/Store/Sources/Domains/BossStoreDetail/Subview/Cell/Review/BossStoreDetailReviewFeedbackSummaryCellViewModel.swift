import Combine

import Common
import Model

final class BossStoreDetailReviewFeedbackSummaryCellViewModel: BaseViewModel {
    struct Input {
        let didTapSeeAllButton = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let feedbacks: [FeedbackCountWithRatioResponse]
        let moveToFeedbackList = PassthroughSubject<Void, Never>()
    }

    let input = Input()
    let output: Output

    init(data: [FeedbackCountWithRatioResponse]) {
        self.output = Output(
            feedbacks: data
        )

        super.init()
    }

    override func bind() {
        super.bind()

        input.didTapSeeAllButton
            .subscribe(output.moveToFeedbackList)
            .store(in: &cancellables)
    }
}

extension BossStoreDetailReviewFeedbackSummaryCellViewModel: Identifiable {
    var id: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
}

extension BossStoreDetailReviewFeedbackSummaryCellViewModel: Hashable {
    static func == (lhs: BossStoreDetailReviewFeedbackSummaryCellViewModel, rhs: BossStoreDetailReviewFeedbackSummaryCellViewModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
