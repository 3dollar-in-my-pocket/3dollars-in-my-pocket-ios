import UIKit
import Combine

import Common
import DesignSystem
import PanModal
import Log

final class BossStoreCouponBottomSheetViewController: BaseViewController {
    private let bottomSheet = BossStoreCouponBottomSheet()
    private let viewModel: BossStoreCouponBottomSheetViewModel
    
    static func instance(viewModel: BossStoreCouponBottomSheetViewModel) -> BossStoreCouponBottomSheetViewController {
        return BossStoreCouponBottomSheetViewController(viewModel: viewModel)
    }
    
    init(viewModel: BossStoreCouponBottomSheetViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = bottomSheet
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bindEvent() {
        bottomSheet.closeButton
            .controlPublisher(for: .touchUpInside)
            .withUnretained(self)
            .sink { (owner: BossStoreCouponBottomSheetViewController, _) in
                owner.dismiss(animated: true)
            }
            .store(in: &cancellables)
    }
    
    override func bindViewModelInput() {
        bottomSheet.useButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapUseCoupon)
            .store(in: &cancellables)
    }
    
    override func bindViewModelOutput() {
        bottomSheet.couponView.bind(viewModel: viewModel.output.couponViewModel)
        
        viewModel.output.errorAlert
            .main
            .withUnretained(self)
            .sink { (owner: BossStoreCouponBottomSheetViewController, error) in
                owner.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: BossStoreCouponBottomSheetViewController, route) in
                switch route {
                case .dismiss:
                    owner.dismiss(animated: true)
                }
            }
            .store(in: &cancellables)
        
        viewModel.output.showConfirmAlert
            .main
            .withUnretained(self)
            .sink { (owner: BossStoreCouponBottomSheetViewController, _) in
                let viewController = BossStoreCouponAlertViewController { [weak owner] in
                    owner?.viewModel.input.useCoupon.send()
                }
                
                owner.present(viewController, animated: true)
            }
            .store(in: &cancellables)
        
        viewModel.output.showToast
            .main
            .sink { ToastManager.shared.show(message: $0) }
            .store(in: &cancellables)
        
        viewModel.output.showLoading
            .removeDuplicates()
            .main
            .sink { LoadingManager.shared.showLoading(isShow: $0) }
            .store(in: &cancellables)
    }
}

extension BossStoreCouponBottomSheetViewController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(375 - UIUtils.bottomSafeAreaInset)
    }
    
    var longFormHeight: PanModalHeight {
        return .contentHeight(375 - UIUtils.bottomSafeAreaInset)
    }
    
    var cornerRadius: CGFloat {
        return 24
    }
    
    var showDragIndicator: Bool {
        return false
    }
}
