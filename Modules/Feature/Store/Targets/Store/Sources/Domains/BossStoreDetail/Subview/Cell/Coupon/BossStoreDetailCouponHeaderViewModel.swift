import Combine

import Common
import Model

final class BossStoreDetailCouponHeaderViewModel: BaseViewModel {
    struct Input {
        let didTapRightButton = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let title: String
        let buttonTitle: String?
        
        let moveToCouponList = PassthroughSubject<Void, Never>()
    }

    let input = Input()
    let output: Output

    override init() {
        self.output = Output(
            title: "쿠폰",
            buttonTitle: "내 쿠폰함 가기"
        )

        super.init()
    }

    override func bind() {
        super.bind()

        input.didTapRightButton
            .subscribe(output.moveToCouponList)
            .store(in: &cancellables)
    }
}

extension BossStoreDetailCouponHeaderViewModel: Identifiable {
    var id: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
}

extension BossStoreDetailCouponHeaderViewModel: Hashable {
    static func == (lhs: BossStoreDetailCouponHeaderViewModel, rhs: BossStoreDetailCouponHeaderViewModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
