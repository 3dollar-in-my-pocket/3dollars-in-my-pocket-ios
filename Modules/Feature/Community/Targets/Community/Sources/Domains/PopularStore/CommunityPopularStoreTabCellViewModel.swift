import Combine

import Common
import Model

final class CommunityPopularStoreTabCellViewModel: BaseViewModel {
    struct Input {

    }

    struct Output {
        let storeList: [PlatformStore]
    }

    struct Config {
    }

    let input = Input()
    let output: Output

    init(storeList: [PlatformStore]) {
        self.output = Output(storeList: storeList)

        super.init()
    }

    override func bind() {
    }
}

extension CommunityPopularStoreTabCellViewModel: Hashable {
    static func == (lhs: CommunityPopularStoreTabCellViewModel, rhs: CommunityPopularStoreTabCellViewModel) -> Bool {
        return true
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine("")
    }
}
