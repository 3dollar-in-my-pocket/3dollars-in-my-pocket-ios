import Foundation

import Common
import DesignSystem


final class AddressConfirmPopupViewController: BaseViewController {
    private let addressConfirmPopupView = AddressConfirmPopupView()
    private let viewModel: AddressConfirmPopupViewModel
    
    init(viewModel: AddressConfirmPopupViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = addressConfirmPopupView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let parentView = presentingViewController?.view {
            DimManager.shared.showDim(targetView: parentView)
        }
        
        viewModel.input.viewDidLoad.send(())
    }
    
    override func bindEvent() {
        addressConfirmPopupView.backgroundView
            .gesture(.tap())
            .withUnretained(self)
            .sink { owner, _ in
                owner.dismiss()
            }
            .store(in: &cancellables)
        
        addressConfirmPopupView.closeButton
            .controlPublisher(for: .touchUpInside)
            .withUnretained(self)
            .sink { owner, _ in
                owner.dismiss()
            }
            .store(in: &cancellables)
    }
    
    override func bindViewModelInput() {
        addressConfirmPopupView.okButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.tapOk)
            .store(in: &cancellables)
    }
    
    override func bindViewModelOutput() {
        viewModel.output.address
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink(receiveValue: { owner, address in
                owner.addressConfirmPopupView.bind(address: address)
            })
            .store(in: &cancellables)
        
        viewModel.output.route
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, route in
                switch route {
                case .dismiss:
                    owner.dismiss()
                }
            }
            .store(in: &cancellables)
    }
    
    private func dismiss() {
        DimManager.shared.hideDim()
        dismiss(animated: true)
    }
}
