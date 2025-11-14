import Foundation
import Combine

import Common

extension BossAppBottomSheetViewModel {
    struct Input {
        let didTapInstall = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let openUrl = PassthroughSubject<String, Never>()
    }
}

final class BossAppBottomSheetViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    
    override func bind() {
        input.didTapInstall
            .sink { [weak self] in
                
                let url = "https://massive-iguana-121.notion.site/3-28c7ad52990e809caba2fb2040677a2a?pvs=74"
                self?.output.openUrl.send(url)
            }
            .store(in: &cancellables)
    }
} 
