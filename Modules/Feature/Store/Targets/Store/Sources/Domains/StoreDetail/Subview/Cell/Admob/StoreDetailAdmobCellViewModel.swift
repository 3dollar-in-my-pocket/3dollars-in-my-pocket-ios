import UIKit

import Common

extension StoreDetailAdmobCellViewModel {
    struct Output {
        let rootViewController: UIViewController
    }
    
    struct Config {
        let rootViewController: UIViewController
    }
}

final class StoreDetailAdmobCellViewModel: BaseViewModel {
    let output: Output
    
    init(config: Config) {
        self.output = Output(rootViewController: config.rootViewController)
        
        super.init()
    }
}

extension StoreDetailAdmobCellViewModel: Identifiable {
    var id: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
}

extension StoreDetailAdmobCellViewModel: Hashable, Equatable {
    static func == (lhs: StoreDetailAdmobCellViewModel, rhs: StoreDetailAdmobCellViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
