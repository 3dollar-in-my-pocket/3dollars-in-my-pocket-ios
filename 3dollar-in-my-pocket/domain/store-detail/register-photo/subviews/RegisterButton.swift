import UIKit

import RxSwift
import RxCocoa

final class RegisterButton: BaseView {
    private let registerButtonBackground = UIView().then {
        $0.backgroundColor = UIColor(r: 255, g: 255, b: 255, a: 0.6)
        $0.layer.cornerRadius = 32
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.1
        $0.layer.shadowOffset = CGSize(width: 10, height: 10)
    }
  
    fileprivate let registerButton = UIButton().then {
        $0.setTitle(String(format: "register_photo_button_format".localized, 0), for: .normal)
        $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 16)
        $0.isEnabled = false
        $0.setBackgroundColor(UIColor.init(r: 208, g: 208, b: 208), for: .disabled)
        $0.setBackgroundColor(UIColor.init(r: 255, g: 92, b: 67), for: .normal)
        $0.layer.cornerRadius = 24
        $0.layer.masksToBounds = true
    }
    
    override func setup() {
        self.addSubViews([
            self.registerButtonBackground,
            self.registerButton
        ])
    }
    
    override func bindConstraints() {
        self.registerButtonBackground.snp.makeConstraints { make in
          make.centerX.equalToSuperview()
          make.bottom.equalToSuperview()
          make.width.equalTo(232)
          make.height.equalTo(64)
        }
        
        self.registerButton.snp.makeConstraints { make in
          make.left.equalTo(self.registerButtonBackground).offset(8)
          make.top.equalTo(self.registerButtonBackground).offset(8)
          make.right.equalTo(self.registerButtonBackground).offset(-8)
          make.bottom.equalTo(self.registerButtonBackground).offset(-8)
        }
        
        self.snp.makeConstraints { make in
            make.edges.equalTo(self.registerButtonBackground).priority(.high)
        }
    }
}

extension Reactive where Base: RegisterButton {
    var tap: ControlEvent<Void> {
        return base.registerButton.rx.tap
    }
    
    var inEnable: Binder<Bool> {
        return base.registerButton.rx.isEnabled
    }
}
