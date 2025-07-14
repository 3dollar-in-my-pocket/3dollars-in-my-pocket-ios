import Foundation
import Combine
import Common
import Model

extension AddressConfirmBottomSheetViewModel {
    struct Input {
        let didTapConfirm = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let stores: [StoreWithExtraResponse]
        let address: String
        let didTapConfirm = PassthroughSubject<Void, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case dismiss
    }
    
    struct Config {
        let stores: [StoreWithExtraResponse]
        let address: String
    }
}

final class AddressConfirmBottomSheetViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    
    init(config: Config) {
        self.output = Output(stores: config.stores, address: config.address)
        
        super.init()
    }
    
    override func bind() {
        input.didTapConfirm
            .sink { [weak self] in
                self?.output.route.send(.dismiss)
                self?.output.didTapConfirm.send(())
            }
            .store(in: &cancellables)
    }
} 
