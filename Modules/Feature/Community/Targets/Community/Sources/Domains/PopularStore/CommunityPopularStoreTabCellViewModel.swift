import Combine

import Common
import Model

final class CommunityPopularStoreTabCellViewModel: BaseViewModel {
    struct Input {

    }

    struct Output {
        let storeList: [PlatformStore]
        let district: String
    }

    struct Config {
    }

    let input = Input()
    let output: Output

    private let userDefaultsUtil: UserDefaultsUtil

    init(
        storeList: [PlatformStore],
        userDefaultsUtil: UserDefaultsUtil = .shared
    ) {
        self.userDefaultsUtil = userDefaultsUtil
        self.output = Output(
            storeList: storeList,
            district: userDefaultsUtil.communityPopularStoreNeighborhoods.description
        )

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
