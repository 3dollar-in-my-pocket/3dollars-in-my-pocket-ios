import Foundation
import Combine

final class AddressConfirmPopupViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let tapOk = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let address = PassthroughSubject<String, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case dismiss
    }
    
    private struct State {
        let address: String
    }
    
    let input = Input()
    let output = Output()
    private let state: State
    private var cancellables = Set<AnyCancellable>()
    private let analyticsManager: AnalyticsManagerProtocol
    
    init(
        address: String,
        analyticsManager: AnalyticsManagerProtocol = AnalyticsManager.shared
    ) {
        self.state = State(address: address)
        self.analyticsManager = analyticsManager
        
        bind()
    }
    
    private func bind() {
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
            .map { owner, _ in
                Route.dismiss
            }
            .subscribe(output.route)
            .store(in: &cancellables)
    }
    
    private func sendPageViewLog() {
        analyticsManager.logPageView(screen: .writeAddressPopup, type: AddressConfirmPopupViewController.self)
    }
    
    private func sendClickOkLog(address: String) {
        analyticsManager.logEvent(event: .clickAddressOk(address: address), screen: .writeAddressPopup)
    }
}
