import UIKit
import RxSwift

final class PopupViewController: BaseVC, PopupCoordinator {
    
    weak var coordinator: PopupCoordinator?
    private let popupView = PopupView()
    private let viewModel: PopupViewModel
    
    init(advertisement: Advertisement) {
        self.viewModel = PopupViewModel(advertisement: advertisement, userDefaults: UserDefaultsUtil())
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func instance(advertisement: Advertisement) -> PopupViewController {
        return PopupViewController(advertisement: advertisement).then {
            $0.modalPresentationStyle = .fullScreen
            $0.modalTransitionStyle = .crossDissolve
        }
    }
    
    override func loadView() {
        self.view = popupView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coordinator = self
        self.viewModel.input.viewDidLoad.onNext(())
    }
    
    override func bindEvent() {
        self.popupView.cancelButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: self.disposeBag)
    }
    
    override func bindViewModelInput() {
        self.popupView.bannerButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(to: self.viewModel.input.tapBannerButton)
            .disposed(by: self.disposeBag)
        
        self.popupView.disableTodayButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(to: self.viewModel.input.tapDisableButton)
            .disposed(by: self.disposeBag)
    }
    
    override func bindViewModelOutput() {
        self.viewModel.output.advertisement
            .asDriver(onErrorJustReturn: Advertisement())
            .drive(onNext: { [weak self] advertisement in
                self?.popupView.bind(advertisement: advertisement)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.output.dismiss
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.coordinator?.dismiss()
            })
            .disposed(by: self.disposeBag)
    }
}
