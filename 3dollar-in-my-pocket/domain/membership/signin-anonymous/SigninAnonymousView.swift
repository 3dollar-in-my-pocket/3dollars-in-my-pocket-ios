import UIKit
import AuthenticationServices

import Then
import Lottie

final class SigninAnonymousView: BaseView {
    let backButton = UIButton().then {
        $0.setImage(R.image.ic_back()?.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .white
    }
    
    let lottie = AnimationView(name: "signin").then {
        $0.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        $0.contentMode = .scaleAspectFill
        $0.loopMode = .loop
        $0.play()
        $0.clipsToBounds = false
    }
    
    let kakaoButton = UIButton().then {
        $0.layer.cornerRadius = 20
        $0.backgroundColor = R.color.kakaoYellow()
        $0.accessibilityLabel = R.string.localization.sign_in_with_kakao()
    }
    
    private let kakaoLabel = UILabel().then {
        $0.text = R.string.localization.sign_in_with_kakao()
        $0.font = .bold(size: 14)
        $0.textColor = UIColor.init(r: 56, g: 30, b: 31)
        $0.isAccessibilityElement = false
    }
    
    let kakaoImage = UIImageView().then {
        $0.image = R.image.ic_kakao()
    }
    
    let appleButton = ASAuthorizationAppleIDButton(type: .signIn, style: .white).then {
        $0.cornerRadius = 24
    }
    
    private let bottomContainerView = UIView().then {
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        $0.backgroundColor = R.color.gray90()
    }
    
    private let bottomImageView = UIImageView().then {
        $0.image = R.image.img_anonymous()
    }
    
    private let anonymousLabel = UILabel().then {
        $0.font = .regular(size: 16)
        $0.textColor = .white
        $0.numberOfLines = 0
        $0.text = R.string.localization.sign_in_anonymous_description()
        $0.textAlignment = .center
    }
    
    override func setup() {
        self.backgroundColor = UIColor(r: 28, g: 28, b: 28)
        self.addSubViews([
            self.backButton,
            self.lottie,
            self.kakaoButton,
            self.kakaoImage,
            self.kakaoLabel,
            self.appleButton,
            self.bottomContainerView,
            self.bottomImageView,
            self.anonymousLabel
        ])
    }
    
    override func bindConstraints() {
        self.backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(self.safeAreaLayoutGuide).offset(13)
            make.width.equalTo(24)
            make.height.equalTo(24)
        }
        
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
        
        self.anonymousLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide).offset(-21)
        }
        
        self.bottomImageView.snp.makeConstraints { make in
            make.centerX.equalTo(self.anonymousLabel)
            make.width.equalTo(40)
            make.height.equalTo(40)
            make.bottom.equalTo(self.anonymousLabel.snp.top).offset(-11)
        }
        
        self.bottomContainerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(self.bottomImageView.snp.centerY)
        }
    }
}
