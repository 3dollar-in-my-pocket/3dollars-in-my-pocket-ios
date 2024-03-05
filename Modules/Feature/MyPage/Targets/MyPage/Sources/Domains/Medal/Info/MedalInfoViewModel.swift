import Foundation
import Combine

import Networking
import Model
import Common
import Log

final class MedalInfoViewModel: BaseViewModel {
    struct Config {
        let medals: [Medal]
    }
    
    struct Output {
        let medals: [Medal]
    }
    
    let output: Output
    
    init(config: Config) {
        self.output = Output(medals: config.medals)
        
        super.init()
    }
}
