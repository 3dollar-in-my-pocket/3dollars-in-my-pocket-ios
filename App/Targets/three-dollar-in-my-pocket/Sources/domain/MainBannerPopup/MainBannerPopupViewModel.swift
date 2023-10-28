import UIKit
import Combine

import Common
import Model

final class MainBannerPopupViewModel: Common.BaseViewModel {
    struct Input {
        let didTapBanner = PassthroughSubject<Void, Never>()
        let didTapDisableToday = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let advertisement: CurrentValueSubject<Model.Advertisement, Never>
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case dismiss
    }
    
    struct State {
        let advertisement: Model.Advertisement
    }
    
    struct Config {
        let advertisement: Model.Advertisement
    }
    
    let input = Input()
    let output: Output
    private var state: State
    private let userDefaults: Common.UserDefaultsUtil
    
    init(config: Config, userDefaults: Common.UserDefaultsUtil = .shared) {
        self.output = Output(advertisement: .init(config.advertisement))
        self.state = State(advertisement: config.advertisement)
        self.userDefaults = userDefaults
        
        super.init()
    }
    
    override func bind() {
        input.didTapBanner
            .withUnretained(self)
            .sink(receiveValue: { (owner: MainBannerPopupViewModel, _) in
                AnalyticsManager.shared.logEvent(
                    event: .splashPopupClicked(id: String(owner.state.advertisement.advertisementId)),
                    screen: .splashPopup
                )
                owner.openEventURL(advertisement: owner.state.advertisement)
            })
            .store(in: &cancellables)
        
        input.didTapDisableToday
            .withUnretained(self)
            .sink(receiveValue: { (owner: MainBannerPopupViewModel, _) in
                owner.userDefaults.setShownMainBannerDate(id: owner.state.advertisement.advertisementId)
                owner.output.route.send(.dismiss)
            })
            .store(in: &cancellables)
    }
    
    private func openEventURL(advertisement: Model.Advertisement) {
        guard let urlString = advertisement.linkUrl,
              let url = URL(string: urlString),
              UIApplication.shared.canOpenURL(url) else { return }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        output.route.send(.dismiss)
    }
}
