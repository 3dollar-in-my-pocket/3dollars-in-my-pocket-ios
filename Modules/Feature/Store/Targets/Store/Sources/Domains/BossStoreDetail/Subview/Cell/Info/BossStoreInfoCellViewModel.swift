import Combine

import Common
import Model

final class BossStoreInfoCellViewModel: BaseViewModel {
    struct Input {

    }

    struct Output {
        let updatedAt: String
        let snsUrl: String?
        let introduction: String?
        let imageUrl: String?
    }

    let input = Input()
    let output: Output

    init(data: BossStoreDetailData) {
        self.output = Output(
            updatedAt: DateUtils.toString(dateString: data.store.updatedAt, format: "yyyy.MM.dd 업데이트"),
            snsUrl: data.overview.snsUrl,
            introduction: data.store.introdution,
            imageUrl: data.store.imageUrl
        )

        super.init()
    }

    override func bind() {

    }
}

extension BossStoreInfoCellViewModel: Identifiable {
    var id: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
}

extension BossStoreInfoCellViewModel: Hashable {
    static func == (lhs: BossStoreInfoCellViewModel, rhs: BossStoreInfoCellViewModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
