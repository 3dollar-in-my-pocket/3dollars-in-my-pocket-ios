import Combine

import Common
import Model

final class BossStoreFeedbacksCellViewModel: BaseViewModel {
    struct Input {
        
    }

    struct Output {
        let feedbacks: [FeedbackCountWithRatioResponse]
    }

    let input = Input()
    let output: Output

    init(data: [FeedbackCountWithRatioResponse]) {
        self.output = Output(feedbacks: data)

        super.init()
    }

    override func bind() {

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
