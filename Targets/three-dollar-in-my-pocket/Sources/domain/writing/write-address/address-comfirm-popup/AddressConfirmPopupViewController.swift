import Foundation

protocol AddressConfirmPopupViewControllerDelegate: AnyObject {
    func onDismiss()
    
    func onClickOk()
}

final class AddressConfirmPopupViewController: BaseVC, AddressConfirmPopupCoordinator {
    weak var delegate: AddressConfirmPopupViewControllerDelegate?
    private let addressConfirmPopupView = AddressConfirmPopupView()
    private weak var coordinator: AddressConfirmPopupCoordinator?
    
    static func instacne(address: String) -> AddressConfirmPopupViewController {
        return AddressConfirmPopupViewController(address: address).then {
            $0.modalPresentationStyle = .overCurrentContext
        }
    }
    
    init(address: String) {
        super.init(nibName: nil, bundle: nil)
        
        self.addressConfirmPopupView.bind(address: address)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = self.addressConfirmPopupView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coordinator = self
    }
    
    override func bindEvent() {
        self.addressConfirmPopupView.tapBackground.rx.event
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.dismiss()
                self?.delegate?.onDismiss()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.addressConfirmPopupView.closeButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.dismiss()
                self?.delegate?.onDismiss()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.addressConfirmPopupView.okButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.coordinator?.dismiss()
                self?.delegate?.onClickOk()
            })
            .disposed(by: self.eventDisposeBag)
    }
}
