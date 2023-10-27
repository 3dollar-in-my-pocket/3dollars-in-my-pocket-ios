import UIKit

import Common
import Model

final class MainBannerPopupViewController: Common.BaseViewController {
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
    
    override func bindEvent() {
        mainBannerPopupView.cancelButton.controlPublisher(for: .touchUpInside)
            .main
            .withUnretained(self)
            .sink(receiveValue: { (owner: MainBannerPopupViewController, _) in
                owner.dismiss(animated: true, completion: nil)
            })
            .store(in: &cancellables)
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
    }
    
    override func bindViewModelOutput() {
        viewModel.output.advertisement
            .main
            .withUnretained(self)
            .sink(receiveValue: { (owner: MainBannerPopupViewController, advertisement: Model.Advertisement) in
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
        }
    }
}
