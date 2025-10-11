import UIKit

import Common
import DesignSystem

final class BossStoreCouponAlertViewController: BaseViewController {
    let didTapDelete: (() -> Void)
    private let alertView = BossStoreCouponAlertView()
    
    init(didTapDelete: @escaping () -> Void) {
        self.didTapDelete = didTapDelete
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = alertView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let parentView = presentingViewController?.view {
            DimManager.shared.showDim(targetView: parentView)
        }
    }
    
    override func bindEvent() {
        alertView.cancelButton
            .controlPublisher(for: .touchUpInside)
            .main
            .withUnretained(self)
            .sink { (owner: BossStoreCouponAlertViewController, _) in
                owner.dismiss()
            }
            .store(in: &cancellables)
        
        alertView.deleteButton
            .controlPublisher(for: .touchUpInside)
            .main
            .withUnretained(self)
            .sink { (owner: BossStoreCouponAlertViewController, _) in
                owner.dismiss()
                owner.didTapDelete()
            }
            .store(in: &cancellables)
    }
    
    private func dismiss() {
        DimManager.shared.hideDim()
        dismiss(animated: true)
    }
}
