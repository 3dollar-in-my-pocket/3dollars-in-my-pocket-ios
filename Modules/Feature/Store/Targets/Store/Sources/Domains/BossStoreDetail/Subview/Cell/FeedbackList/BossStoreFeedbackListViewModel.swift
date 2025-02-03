import Foundation
import Combine

import Networking
import Model
import Common
import Log

final class BossStoreFeedbackListViewModel: BaseViewModel {
    struct Input {
        let didTapReviewWrtieButton = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let feedbacks: [FeedbackCountWithRatioResponse]
        let feedbackTotalCount: Int
        
        let moveToReviewWrite = PassthroughSubject<Void, Never>()
    }

    let input = Input()
    let output: Output

    init(data: [FeedbackCountWithRatioResponse]) {
        output = Output(
            feedbacks: data,
            feedbackTotalCount: data.map { $0.count }.reduce(0, +)
        )
        
        super.init()
    }

    override func bind() {
        super.bind()

        input.didTapReviewWrtieButton
            .subscribe(output.moveToReviewWrite)
            .store(in: &cancellables)
    }
}
