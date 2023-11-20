import Combine

import Common
import Model

final class BossStoreFeedbacksCellViewModel: BaseViewModel {
    struct Input {
        let didTapSendFeedbackButton = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let feedbacks: [FeedbackCountWithRatioResponse]
        let feedbackTotalCount: Int
        let didTapSendFeedbackButton = PassthroughSubject<Void, Never>()
    }

    let input = Input()
    let output: Output

    init(data: [FeedbackCountWithRatioResponse]) {
        self.output = Output(
            feedbacks: data,
            feedbackTotalCount: data.map { $0.count }.reduce(0, +)
        )

        super.init()
    }

    override func bind() {
        super.bind()

        input.didTapSendFeedbackButton
            .subscribe(output.didTapSendFeedbackButton)
            .store(in: &cancellables)
    }
}

extension BossStoreFeedbacksCellViewModel: Identifiable {
    var id: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
}

extension BossStoreFeedbacksCellViewModel: Hashable {
    static func == (lhs: BossStoreFeedbacksCellViewModel, rhs: BossStoreFeedbacksCellViewModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
