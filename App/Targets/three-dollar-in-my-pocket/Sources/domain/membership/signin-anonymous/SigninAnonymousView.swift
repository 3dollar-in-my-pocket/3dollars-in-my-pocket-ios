import UIKit
import AuthenticationServices

import DesignSystem
import Then

final class SigninAnonymousView: BaseView {
    let closeButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_close_white"), for: .normal)
        $0.tintColor = .white
    }
    
    let logoText = UIImageView().then {
        $0.image = UIImage(named: "img_signin_background")
        $0.contentMode = .scaleAspectFill
    }
    
    let kakaoButton = SocialSigninButton(socialType: .kakao)
    
    let appleButton = SocialSigninButton(socialType: .apple)
    
    private let anonymousLabel = UILabel().then {
        $0.font = .regular(size: 14)
        $0.textColor = .white
        $0.numberOfLines = 0
        $0.text = "sign_in_anonymous_description".localized
        $0.textAlignment = .center
        $0.setLineHeight(lineHeight: 20)
    }
    
    override func setup() {
        self.backgroundColor = DesignSystemAsset.Colors.mainPink.color
        self.addSubViews([
            self.closeButton,
            self.logoText,
            self.kakaoButton,
            self.appleButton,
            self.anonymousLabel
        ])
    }
    
    override func bindConstraints() {
        self.closeButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(self.safeAreaLayoutGuide).offset(13)
            make.width.equalTo(24)
            make.height.equalTo(24)
        }
        
        self.logoText.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-33)
            make.top.equalToSuperview().offset(213)
            make.height.equalTo(178)
        }
        
        self.kakaoButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(31)
            make.right.equalToSuperview().offset(-32)
            make.top.equalTo(self.logoText.snp.bottom).offset(48)
        }
        
        self.appleButton.snp.makeConstraints { make in
            make.left.right.equalTo(kakaoButton)
            make.top.equalTo(self.kakaoButton.snp.bottom).offset(16)
        }
        
        self.anonymousLabel.snp.makeConstraints { make in
            make.centerX.equalTo(self.kakaoButton)
            make.top.equalTo(self.appleButton.snp.bottom).offset(36)
        }
    }
}
