import UIKit

import Common
import Model
import Log

final class MainBannerPopupViewController: BaseViewController {
    public override var screenName: ScreenName {
        return viewModel.output.screenName
    }
    
    private let mainBannerPopupView = MainBannerPopupView()
    private let viewModel: MainBannerPopupViewModel
    
    init(viewModel: MainBannerPopupViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = mainBannerPopupView
    }
    
    override func bindViewModelInput() {
        mainBannerPopupView.bannerButton.controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapBanner)
            .store(in: &cancellables)
        
        mainBannerPopupView.disableTodayButton.controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapDisableToday)
            .store(in: &cancellables)
        
        mainBannerPopupView.cancelButton.controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapClose)
            .store(in: &cancellables)
    }
    
    override func bindViewModelOutput() {
        viewModel.output.advertisement
            .main
            .withUnretained(self)
            .sink(receiveValue: { (owner: MainBannerPopupViewController, advertisement: AdvertisementResponse) in
                owner.mainBannerPopupView.bind(advertisement: advertisement)
            })
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink(receiveValue: { (owner: MainBannerPopupViewController, route: MainBannerPopupViewModel.Route) in
                owner.handleRoute(route)
            })
            .store(in: &cancellables)
    }
    
    private func handleRoute(_ route: MainBannerPopupViewModel.Route) {
        switch route {
        case .dismiss:
            dismiss(animated: true, completion: nil)
        case .deepLink(let advertisement):
            dismiss(animated: true) {
                guard let link = advertisement.link else { return }
                DeepLinkHandler.shared.handleAdvertisementLink(link)
            }
        }
    }
}
