import UIKit

import RxSwift
import RxCocoa

final class DeleteMenuStackView: UIStackView {
    let notExistedButton = DeleteMenuButton().then {
        $0.setTitle("store_delete_menu_not_existed".localized, for: .normal)
    }
    
    let wrongContentButton = DeleteMenuButton().then {
        $0.setTitle("store_delete_menu_wrong_content".localized, for: .normal)
    }
    
    let overlapButton = DeleteMenuButton().then {
        $0.setTitle("store_delete_menu_overlap".localized, for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
        self.bindConstraints()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func select(deleteReason: DeleteReason) {
        self.clearSelected()
        switch deleteReason {
        case .NOSTORE:
            self.notExistedButton.isSelected = true
            
        case .WRONGCONTENT:
            self.wrongContentButton.isSelected = true
            
        case .OVERLAPSTORE:
            self.overlapButton.isSelected = true
        }
    }
    
    private func setup() {
        self.alignment = .top
        self.axis = .vertical
        self.backgroundColor = .clear
        self.spacing = 10
        self.distribution = .equalSpacing
        
        self.addArrangedSubview(self.notExistedButton)
        self.addArrangedSubview(self.wrongContentButton)
        self.addArrangedSubview(self.overlapButton)
    }
    
    private func bindConstraints() {
        self.notExistedButton.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.left.right.equalToSuperview()
        }
        
        self.wrongContentButton.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.left.right.equalToSuperview()
        }
        
        self.overlapButton.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.left.right.equalToSuperview()
        }
    }
    
    private func clearSelected() {
        self.arrangedSubviews.forEach { view in
            if let button = view as? UIButton {
                button.isSelected = false
            }
        }
    }
}

extension Reactive where Base: DeleteMenuStackView {
    var selectReason: Binder<DeleteReason> {
        return Binder(self.base) { view, reason in
            view.select(deleteReason: reason)
        }
    }
}
