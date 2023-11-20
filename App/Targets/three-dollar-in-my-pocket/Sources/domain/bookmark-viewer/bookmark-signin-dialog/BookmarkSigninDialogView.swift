import UIKit
import AuthenticationServices

import RxSwift
import RxCocoa

final class BookmarkSigninDialogView: BaseView {
    fileprivate let backgroundButton = UIButton()
    
    private let containerView = UIView().then {
        $0.backgroundColor = Color.gray80
        $0.layer.cornerRadius = 30
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "로그인을 하시면\n더 많은 정보가~~^^*"
        $0.numberOfLines = 0
        $0.textAlignment = .left
        $0.font = .regular(size: 24)
        $0.textColor = Color.gray0
    }
    
    let closeButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_close_white_background"), for: .normal)
    }
    
    let kakaoButton = SocialSigninButton(socialType: .kakao)
    
    let appleButton = SocialSigninButton(socialType: .apple)
    
    override func setup() {
        self.addSubViews([
            self.backgroundButton,
            self.containerView,
            self.titleLabel,
            self.closeButton,
            self.kakaoButton,
            self.appleButton
        ])
    }
    
    override func bindConstraints() {
        self.backgroundButton.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(self.containerView.snp.top)
            }
        
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalTo(self.safeAreaLayoutGuide).offset(-20)
            make.top.equalTo(self.titleLabel).offset(-32)
        }
        
        self.appleButton.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(16)
            make.right.equalTo(self.containerView).offset(-16)
            make.bottom.equalTo(self.containerView).offset(-38)
            make.height.equalTo(40)
        }
        
        self.kakaoButton.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(16)
            make.right.equalTo(self.containerView).offset(-16)
            make.bottom.equalTo(self.appleButton.snp.top).offset(-16)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(24)
            make.bottom.equalTo(self.kakaoButton.snp.top).offset(-54)
            make.right.equalTo(self.closeButton.snp.left)
        }
        
        self.closeButton.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel)
            make.right.equalTo(self.containerView).offset(-24)
            make.width.equalTo(24)
            make.height.equalTo(24)
        }
    }
}

extension Reactive where Base: BookmarkSigninDialogView {
    var tapBackground: ControlEvent<Void> {
        return base.backgroundButton.rx.tap
    }
}
