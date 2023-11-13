import Foundation
import Combine

import Common
import Log

final class AddressConfirmPopupViewModel: BaseViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let tapOk = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .writeAddressPopup
        let address = PassthroughSubject<String, Never>()
        let route = PassthroughSubject<Route, Never>()
        
        let onClickOk = PassthroughSubject<Void, Never>()
    }
    
    enum Route {
        case dismiss
    }
    
    private struct State {
        let address: String
    }
    
    struct Config {
        let address: String
    }
    
    let input = Input()
    let output = Output()
    private let state: State
    private let logManager: LogManagerProtocol
    
    init(config: Config, logManager: LogManagerProtocol = LogManager.shared) {
        self.state = State(address: config.address)
        self.logManager = logManager
        
        super.init()
    }
    
    override func bind() {
        input.viewDidLoad
            .withUnretained(self)
            .map { owner, _ in
                owner.state.address
            }
            .subscribe(output.address)
            .store(in: &cancellables)
        
        input.tapOk
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.sendClickOkLog(address: owner.state.address)
            })
            .sink(receiveValue: { (owner: AddressConfirmPopupViewModel, _) in
                owner.output.route.send(.dismiss)
                owner.output.onClickOk.send(())
            })
            .store(in: &cancellables)
    }
    
    private func sendClickOkLog(address: String) {
        logManager.sendEvent(LogEvent(
            screen: output.screenName,
            eventName: .clickAddressOk,
            extraParameters: [.address: address]
        ))
    }
}
