import Foundation
import Combine

import Common
import AppInterface
import DependencyInjection

final class AddressConfirmPopupViewModel: BaseViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let tapOk = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
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
    private let analyticsManager: AnalyticsManagerProtocol
    
    init(config: Config) {
        self.state = State(address: config.address)
        
        guard let appModuleInterface = DIContainer.shared.container.resolve(AppModuleInterface.self) else {
            fatalError("AppModuleInterface가 정의되지 않았습니다.")
        }
        self.analyticsManager = appModuleInterface.analyticsManager
        
        super.init()
    }
    
    override func bind() {
        input.viewDidLoad
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.sendPageViewLog()
            })
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
    
    private func sendPageViewLog() {
        analyticsManager.logPageView(screen: .writeAddressPopup, type: AddressConfirmPopupViewController.self)
    }
    
    private func sendClickOkLog(address: String) {
        analyticsManager.logEvent(event: .clickAddressOk(address: address), screen: .writeAddressPopup)
    }
}
