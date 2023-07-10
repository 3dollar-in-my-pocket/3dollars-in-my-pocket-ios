// MARK: - 버튼 수정 중 가은
import UIKit
import AuthenticationServices

import DesignSystem
import Then

final class SigninView: BaseView {
    let logoText = UIImageView().then {
        $0.image = UIImage(named: "img_signin_background")
        $0.contentMode = .scaleAspectFill
    }
    
    let kakaoButton = SocialSigninButton(socialType: .kakao)
    
    let appleButton = SocialSigninButton(socialType: .apple)
    
    let signinWithoutIdButton = UIButton().then {
        $0.setTitle("sign_in_without_id".localized, for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .medium(size: 14)
    }
    
    override func setup() {
        self.alpha = 0
        self.backgroundColor = DesignSystemAsset.Colors.mainPink.color
        self.addSubViews([
            self.logoText,
            self.kakaoButton,
            self.appleButton,
            self.signinWithoutIdButton
        ])
    }
    
    override func bindConstraints() {
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
        
        self.signinWithoutIdButton.snp.makeConstraints { make in
            make.centerX.equalTo(self.kakaoButton)
            make.top.equalTo(self.appleButton.snp.bottom).offset(20)
        }
    }
    
    func startFadeIn() {
        DispatchQueue.main.async { [weak self] in
            UIView.animate(withDuration: 0.5) {
                self?.alpha = 1
            }
        }
    }
}
