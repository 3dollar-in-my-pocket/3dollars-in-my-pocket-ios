import Foundation
import Combine

import Common

extension BossAppBottomSheetViewModel {
    struct Input {
        let didTapInstall = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let openAppStore = PassthroughSubject<String, Never>()
    }
}

final class BossAppBottomSheetViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    
    override func bind() {
        input.didTapInstall
            .sink { [weak self] in
                
                let url = "https://apps.apple.com/kr/app/%EA%B0%80%EC%8A%B4%EC%86%8D-3%EC%B2%9C%EC%9B%90-%EC%82%AC%EC%9E%A5%EB%8B%98/id1639708958"
                self?.output.openAppStore.send(url)
            }
            .store(in: &cancellables)
    }
} 
