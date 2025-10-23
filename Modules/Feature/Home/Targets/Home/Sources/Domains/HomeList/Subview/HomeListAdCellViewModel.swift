import Combine

import Common
import Model
import Networking
import Log

final class HomeListAdCellViewModel: BaseViewModel {
    struct Output {
        let item: AdvertisementResponse?
    }

    struct Config {
        let ad: AdvertisementResponse?
    }

    lazy var identifier = ObjectIdentifier(self)

    let output: Output
    let config: Config

    init(config: Config) {
        self.config = config
        self.output = Output(item: config.ad)

        super.init()
    }

    override func bind() {
        super.bind()
    }
}

extension HomeListAdCellViewModel: Hashable {
    static func == (lhs: HomeListAdCellViewModel, rhs: HomeListAdCellViewModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
