import Combine

import Common
import Model

final class BossStoreDetailReviewHeaderViewModel: BaseViewModel {
    struct Input {
        let didTapRightButton = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let title: String
        let description: String?
        let value: String?
        let buttonTitle: String?
        let moveToReviewWrite = PassthroughSubject<Void, Never>()
    }

    let input = Input()
    let output: Output

    init(totalCount: Int) {
        self.output = Output(
            title: Strings.StoreDetail.Review.Header.title,
            description: nil,
            value: " \(totalCount)개",
            buttonTitle: Strings.StoreDetail.Review.Header.button
        )

        super.init()
    }

    override func bind() {
        super.bind()

        input.didTapRightButton
            .subscribe(output.moveToReviewWrite)
            .store(in: &cancellables)
    }
}

extension BossStoreDetailReviewHeaderViewModel: Identifiable {
    var id: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
}

extension BossStoreDetailReviewHeaderViewModel: Hashable {
    static func == (lhs: BossStoreDetailReviewHeaderViewModel, rhs: BossStoreDetailReviewHeaderViewModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
