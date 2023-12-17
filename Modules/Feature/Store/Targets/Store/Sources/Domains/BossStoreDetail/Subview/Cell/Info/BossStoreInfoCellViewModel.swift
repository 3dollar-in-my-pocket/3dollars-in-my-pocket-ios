import Combine

import Common
import Model

final class BossStoreInfoCellViewModel: BaseViewModel {
    struct Input {
        let didTapSnsButton = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let info: BossStoreInfo
        let didTapSnsButton = PassthroughSubject<Void, Never>()
    }

    let input = Input()
    let output: Output
    
    init(info: BossStoreInfo) {
        self.output = Output(info: info)
        super.init()
    }

    override func bind() {
        super.bind()
        
        input.didTapSnsButton
            .subscribe(output.didTapSnsButton)
            .store(in: &cancellables)
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
