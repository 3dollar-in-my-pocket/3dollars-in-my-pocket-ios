import UIKit
import Combine

import Common
import Model
import Log

final class BossStorePostCellViewModel: BaseViewModel {
    struct Input {
    }

    struct Output {
    }
    
    struct Config {
    }

    let input = Input()
    let output: Output
    let config: Config
    
    private let logManager: LogManagerProtocol
    
    init(logManager: LogManagerProtocol = LogManager.shared) {
        self.output = Output()
        self.config = Config()
        self.logManager = logManager
        
        super.init()
    }

    override func bind() {
        super.bind()
        
    }
}

extension BossStorePostCellViewModel: Identifiable {
    var id: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
}

extension BossStorePostCellViewModel: Hashable {
    static func == (lhs: BossStorePostCellViewModel, rhs: BossStorePostCellViewModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: Log
private extension BossStorePostCellViewModel {
    
}
