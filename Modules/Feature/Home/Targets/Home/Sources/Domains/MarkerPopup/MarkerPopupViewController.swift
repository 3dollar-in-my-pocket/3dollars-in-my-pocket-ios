import UIKit
import Combine

import Common
import DesignSystem
import Model

final class MarkerPopupViewController: BaseViewController {
    private let markerPopupView = MarkerPopupView()
    private let viewModel: MarkerPopupViewModel
    
    init(viewModel: MarkerPopupViewModel = .init()) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = markerPopupView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let parentView = self.presentingViewController?.view {
            DimManager.shared.showDim(targetView: parentView)
        }
        
        viewModel.input.viewDidLoad.send(())
    }
    
    override func bindEvent() {
        markerPopupView.closeButton
            .controlPublisher(for: .touchUpInside)
            .main
            .withUnretained(self)
            .sink { (owner: MarkerPopupViewController, _) in
                owner.dismiss()
            }
            .store(in: &cancellables)
        
        markerPopupView.backgroundButton
            .controlPublisher(for: .touchUpInside)
            .main
            .withUnretained(self)
            .sink { (owner: MarkerPopupViewController, _) in
                owner.dismiss()
            }
            .store(in: &cancellables)
    }
    
    override func bindViewModelInput() {
        markerPopupView.bottomButton.controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapButton)
            .store(in: &cancellables)
    }
    
    override func bindViewModelOutput() {
        viewModel.output.advertisement
            .main
            .withUnretained(self)
            .sink { (owner: MarkerPopupViewController, advertisement: Advertisement) in
                owner.markerPopupView.bind(advertisement: advertisement)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: MarkerPopupViewController, route: MarkerPopupViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
    }
    
    private func handleRoute(_ route: MarkerPopupViewModel.Route) {
        switch route {
        case .goToURL(let urlString):
            DimManager.shared.hideDim()
            dismiss(animated: true) {
                guard let url = URL(string: urlString) else { return }
                
                UIApplication.shared.open(url)
            }
        }
    }
    
    private func dismiss() {
        DimManager.shared.hideDim()
        dismiss(animated: true, completion: nil)
    }
}
