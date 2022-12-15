import UIKit

import ReactorKit
import RxSwift

final class MarkerPopupViewController: BaseViewController, View, MarkerPopupCoordinator {
    private let markerPopupView = MarkerPopupView()
    private let markerPopupReactor = MarkerPopupReactor(
        advertisementService: AdvertisementService()
    )
    private weak var coordinator: MarkerPopupCoordinator?
    
    static func instacne() -> MarkerPopupViewController {
        return MarkerPopupViewController(nibName: nil, bundle: nil).then {
            $0.modalPresentationStyle = .overCurrentContext
        }
    }
    
    override func loadView() {
        self.view = self.markerPopupView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let parentView = self.presentingViewController?.view {
            DimManager.shared.showDim(targetView: parentView)
        }
        self.coordinator = self
        self.reactor = self.markerPopupReactor
        self.markerPopupReactor.action.onNext(.viewDidLoad)
    }
    
    override func bindEvent() {
        self.markerPopupView.closeButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.dismiss()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.markerPopupView.backgroundButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.dismiss()
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: MarkerPopupReactor) {
        // Bind Action
        self.markerPopupView.downloadButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.tapDownload }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // Bind State
        reactor.state
            .map { $0.advertisement }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: Advertisement())
            .drive(self.markerPopupView.rx.advertisement)
            .disposed(by: self.disposeBag)
        
        reactor.pulse(\.$goToURL)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] urlString in
                self?.coordinator?.openURL(urlString: urlString)
            })
            .disposed(by: self.disposeBag)
    }
}
