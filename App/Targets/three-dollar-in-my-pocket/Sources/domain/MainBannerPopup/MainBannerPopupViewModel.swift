import UIKit
import Combine

import Common
import Model
import Log

final class MainBannerPopupViewModel: BaseViewModel {
    struct Input {
        let didTapBanner = PassthroughSubject<Void, Never>()
        let didTapDisableToday = PassthroughSubject<Void, Never>()
        let didTapClose = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .mainBannerPopup
        let advertisement: CurrentValueSubject<AdvertisementResponse, Never>
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case dismiss
    }
    
    struct State {
        let advertisement: AdvertisementResponse
    }
    
    struct Config {
        let advertisement: AdvertisementResponse
    }
    
    let input = Input()
    let output: Output
    private var state: State
    private let preference = Preference.shared
    private let logManager: LogManagerProtocol
    
    init(
        config: Config,
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.output = Output(advertisement: .init(config.advertisement))
        self.state = State(advertisement: config.advertisement)
        self.logManager = logManager
        
        super.init()
    }
    
    override func bind() {
        input.didTapBanner
            .withUnretained(self)
            .sink(receiveValue: { (owner: MainBannerPopupViewModel, _) in
                owner.snedClickBannerLog()
                owner.openEventURL(advertisement: owner.state.advertisement)
            })
            .store(in: &cancellables)
        
        input.didTapDisableToday
            .withUnretained(self)
            .sink(receiveValue: { (owner: MainBannerPopupViewModel, _) in
                owner.sendClickNotShowTodayLog()
                owner.preference.setShownMainBannerDate(id: owner.state.advertisement.advertisementId)
                owner.output.route.send(.dismiss)
            })
            .store(in: &cancellables)
        
        input.didTapClose
            .withUnretained(self)
            .sink { (owner: MainBannerPopupViewModel, _) in
                owner.sendClickCloseLog()
                owner.output.route.send(.dismiss)
            }
            .store(in: &cancellables)
    }
    
    private func openEventURL(advertisement: AdvertisementResponse) {
        guard let urlString = advertisement.link?.url,
              let url = URL(string: urlString),
              UIApplication.shared.canOpenURL(url) else { return }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        output.route.send(.dismiss)
    }
    
    private func snedClickBannerLog() {
        logManager.sendEvent(LogEvent(
            screen: .mainBannerPopup,
            eventName: .clickAdBanner,
            extraParameters: [
                .advertisementId: state.advertisement.advertisementId
            ]))
    }
    
    private func sendClickNotShowTodayLog() {
        logManager.sendEvent(LogEvent(
            screen: .mainBannerPopup,
            eventName: .clickNotShowToday
        ))
    }
    
    private func sendClickCloseLog() {
        logManager.sendEvent(LogEvent(
            screen: .mainBannerPopup,
            eventName: .clickClose
        ))
    }
}
