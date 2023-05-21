import UIKit
import AuthenticationServices

import Then
import Lottie

final class SigninView: BaseView {
    let lottie = LottieAnimationView(name: "signin").then {
        $0.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        $0.contentMode = .scaleAspectFill
        $0.loopMode = .loop
        $0.play()
        $0.clipsToBounds = false
    }
    
    let kakaoButton = UIButton().then {
        $0.layer.cornerRadius = 20
        $0.backgroundColor = Color.kakaoYellow
        $0.accessibilityLabel = "sign_in_with_kakao".localized
    }
    
    private let kakaoLabel = UILabel().then {
        $0.text = "sign_in_with_kakao".localized
        $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 14)
        $0.textColor = UIColor.init(r: 56, g: 30, b: 31)
        $0.isAccessibilityElement = false
    }
    
    let kakaoImage = UIImageView().then {
        $0.image = UIImage(named: "ic_kakao")
    }
    
    let appleButton = ASAuthorizationAppleIDButton(type: .signIn, style: .white).then {
        $0.cornerRadius = 24
    }
    
    let signinWithoutIdButton = UIButton().then {
        $0.setTitle("sign_in_without_id".localized, for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .medium(size: 14)
    }
    
    override func setup() {
        self.alpha = 0
        self.backgroundColor = UIColor(r: 28, g: 28, b: 28)
        self.addSubViews([
            self.lottie,
            self.kakaoButton,
            self.kakaoImage,
            self.kakaoLabel,
            self.appleButton,
            self.signinWithoutIdButton
        ])
    }
    
    override func bindConstraints() {
        self.lottie.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(109)
            make.height.equalTo(350)
        }
        
        self.appleButton.snp.makeConstraints { make in
            make.left.right.equalTo(kakaoButton)
            make.top.equalTo(self.kakaoButton.snp.bottom).offset(16)
            make.height.equalTo(40)
        }
        
        self.kakaoButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(31)
            make.right.equalToSuperview().offset(-32)
            make.top.equalTo(self.lottie.snp.bottom).offset(30)
            make.height.equalTo(40)
        }
        
        self.kakaoLabel.snp.makeConstraints { make in
            make.center.equalTo(self.kakaoButton)
        }
        
        self.kakaoImage.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.kakaoLabel)
            make.right.equalTo(self.kakaoLabel.snp.left).offset(-6)
            make.width.height.equalTo(16)
        }
        
        self.signinWithoutIdButton.snp.makeConstraints { make in
            make.centerX.equalTo(self.kakaoButton)
            make.top.equalTo(self.appleButton.snp.bottom).offset(32)
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
