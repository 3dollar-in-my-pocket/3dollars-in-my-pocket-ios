import UIKit
import Combine

import Common
import Model
import Log

final class BossStoreInfoCellViewModel: BaseViewModel {
    struct Input {
        let didTapSnsButton = PassthroughSubject<Void, Never>()
        let didTapPhoto = PassthroughSubject<Int, Never>()
    }

    struct Output {
        let info: BossStoreInfo
        let didTapSnsButton = PassthroughSubject<Void, Never>()
        let didTapPhoto = PassthroughSubject<Int, Never>()
        let toast = PassthroughSubject<String, Never>()
    }
    
    struct Config {
        let screenName: ScreenName
        let storeId: String
        let info: BossStoreInfo
    }

    let input = Input()
    let output: Output
    let config: Config
    private let logManager: LogManagerProtocol
    
    init(config: Config, logManager: LogManagerProtocol = LogManager.shared) {
        self.output = Output(info: config.info)
        self.config = config
        self.logManager = logManager
        super.init()
    }

    override func bind() {
        super.bind()
        
        input.didTapSnsButton
            .subscribe(output.didTapSnsButton)
            .store(in: &cancellables)
        
        input.didTapPhoto
            .subscribe(output.didTapPhoto)
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
