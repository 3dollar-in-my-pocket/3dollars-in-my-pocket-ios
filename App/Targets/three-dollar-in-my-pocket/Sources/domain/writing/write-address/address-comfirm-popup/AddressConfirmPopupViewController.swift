import Foundation

protocol AddressConfirmPopupViewControllerDelegate: AnyObject {
    func onClickOk()
}

final class AddressConfirmPopupViewController: BaseBottomSheetViewController, AddressConfirmPopupCoordinator {
    weak var delegate: AddressConfirmPopupViewControllerDelegate?
    private let addressConfirmPopupView = AddressConfirmPopupView()
    private weak var coordinator: AddressConfirmPopupCoordinator?
    
    static func instacne(address: String) -> AddressConfirmPopupViewController {
        return AddressConfirmPopupViewController(address: address)
    }
    
    init(address: String) {
        super.init(nibName: nil, bundle: nil)
        
        addressConfirmPopupView.bind(address: address)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = addressConfirmPopupView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coordinator = self
    }
    
    override func bindEvent() {
        addressConfirmPopupView.backgroundView
            .gesture(.tap())
            .withUnretained(self)
            .sink { owner, _ in
                owner.coordinator?.dismiss()
            }
            .store(in: &cancellables)
        
        addressConfirmPopupView.closeButton
            .controlPublisher(for: .touchUpInside)
            .withUnretained(self)
            .sink { owner, _ in
                owner.coordinator?.dismiss()
            }
            .store(in: &cancellables)
        
        addressConfirmPopupView.okButton
            .controlPublisher(for: .touchUpInside)
            .withUnretained(self)
            .sink(receiveValue: { owner, _ in
                owner.coordinator?.dismiss(completion: {
                    owner.delegate?.onClickOk()
                })
            })
            .store(in: &cancellables)
    }
}
