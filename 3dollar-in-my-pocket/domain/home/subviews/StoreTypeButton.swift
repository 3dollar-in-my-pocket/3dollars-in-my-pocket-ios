import UIKit

import RxSwift
import RxCocoa

final class StoreTypeButton: BaseView {
    fileprivate let containerButton = UIButton().then {
        $0.backgroundColor = Color.gray90
        $0.layer.cornerRadius = 10
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.08
        $0.layer.shadowOffset = CGSize(width: 2, height: 2)
    }
    
    fileprivate let iconView = UIImageView().then {
        $0.image = UIImage(named: "ic_sync")?.withRenderingMode(.alwaysTemplate)
        $0.tintColor = Color.green
    }
    
    fileprivate let titleLabel = UILabel().then {
        $0.font = .bold(size: 12)
        $0.textColor = Color.green
        $0.text = "푸드트럭"
    }
    
    override func setup() {
        self.addSubViews([
            self.containerButton,
            self.iconView,
            self.titleLabel
        ])
    }
    
    override func bindConstraints() {
        self.containerButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(44)
        }
        
        self.iconView.snp.makeConstraints { make in
            make.left.equalTo(self.containerButton).offset(10)
            make.centerY.equalTo(self.containerButton)
            make.width.equalTo(16)
            make.height.equalTo(16)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.iconView)
            make.left.equalTo(self.iconView.snp.right).offset(4)
            make.right.equalTo(self.containerButton).offset(-10)
        }
    }
    
    fileprivate func setType(type: StoreType) {
        self.iconView.tintColor = type.themeColor
        self.titleLabel.textColor = type.themeColor
        self.titleLabel.text = type.title
    }
}

extension Reactive where Base: StoreTypeButton {
    var tap: ControlEvent<Void> {
        return base.containerButton.rx.tap
    }
    
    var storeType: Binder<StoreType> {
        return Binder(self.base) { view, storeType in
            view.setType(type: storeType)
        }
    }
}
