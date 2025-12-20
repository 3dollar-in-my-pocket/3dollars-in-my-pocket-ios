import Foundation
import Combine
import Common
import Model
import Log

extension AddressConfirmBottomSheetViewModel {
    struct Input {
        let didTapConfirm = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let screen: ScreenName = .writeAddressPopup
        let stores: [StoreWithExtraResponse]
        let address: String
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case dismiss
    }
    
    struct Config {
        let stores: [StoreWithExtraResponse]
        let address: String
    }
    
    struct Dependency {
        let logManager: LogManager
        
        init(logManager: LogManager = LogManager.shared) {
            self.logManager = logManager
        }
    }
}

final class AddressConfirmBottomSheetViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    private let dependency: Dependency
    
    init(config: Config, dependency: Dependency = Dependency()) {
        self.output = Output(stores: config.stores, address: config.address)
        self.dependency = dependency
        
        super.init()
    }
    
    override func bind() {
        input.didTapConfirm
            .sink { [weak self] in
                self?.sendClickConfirmButtonLog()
                self?.output.route.send(.dismiss)
            }
            .store(in: &cancellables)
    }
} 

extension AddressConfirmBottomSheetViewModel {
    private func sendClickConfirmButtonLog() {
        dependency.logManager.sendEvent(event: ClickEvent(
            screen: output.screen,
            objectType: .button,
            objectId: .ok
        ))
    }
}
