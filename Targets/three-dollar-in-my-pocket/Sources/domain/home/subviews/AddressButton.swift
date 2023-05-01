import UIKit

import RxSwift
import RxCocoa

final class AddressButton: BaseView {
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 2, height: 2)
        $0.layer.shadowOpacity = 0.08
    }
  
    fileprivate let addressButton = UIButton().then {
        $0.titleLabel?.font = .semiBold(size: 12)
        $0.setTitleColor(.black, for: .normal)
        $0.contentHorizontalAlignment = .left
    }
    
    private let rightArrowImage = UIImageView().then {
        $0.image = UIImage(named: "ic_right_arrow")?
            .withRenderingMode(.alwaysTemplate)
        $0.tintColor = Color.gray30
    }
    
    override func setup() {
        self.addSubViews([
            self.containerView,
            self.addressButton,
            self.rightArrowImage
        ])
    }
    
    override func bindConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(44)
        }
        
        self.addressButton.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(12)
            make.centerY.equalTo(self.containerView)
            make.right.equalTo(self.rightArrowImage).offset(-12)
        }
        
        self.rightArrowImage.snp.makeConstraints { make in
            make.centerY.equalTo(self.containerView)
            make.right.equalTo(self.containerView).offset(-16)
            make.width.equalTo(12)
            make.height.equalTo(12)
        }
        
        self.snp.makeConstraints { make in
            make.edges.equalTo(self.containerView).priority(.high)
        }
    }
}

extension Reactive where Base: AddressButton {
    var tap: ControlEvent<Void> {
        return base.addressButton.rx.tap
    }
    
    var title: Binder<String?> {
        return base.addressButton.rx.title(for: .normal)
    }
}
