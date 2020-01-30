import UIKit
import KakaoOpenSDK
import SnapKit
import Then
import AuthenticationServices
import Lottie

class SignInView: BaseView {
    
    let lottie = LOTAnimationView(name: "signin").then {
        $0.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        $0.contentMode = .scaleAspectFill
        $0.loopAnimation = true
        $0.play()
    }
    
    let kakaoBtn = UIButton().then {
        $0.layer.cornerRadius = 20
        $0.backgroundColor = UIColor.init(r: 247, g: 227, b: 23)
    }
    
    let kakaoLabel = UILabel().then {
        $0.text = "카카오 계정으로 로그인"
        $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 14)
        $0.textColor = UIColor.init(r: 56, g: 30, b: 31)
    }
    
    let kakaoImg = UIImageView().then {
        $0.image = UIImage.init(named: "ic_kakao")
    }
    
    let appleBtn = ASAuthorizationAppleIDButton(type: .signIn, style: .white).then {
        $0.cornerRadius = 24
    }
    
    
    override func setup() {
        alpha = 0
        backgroundColor = UIColor.init(r: 28, g: 28, b: 28)
        addSubViews(lottie, kakaoBtn, kakaoImg, kakaoLabel, appleBtn)
    }
    
    override func bindConstraints() {
        lottie.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(109)
            make.height.equalTo(350)
        }
        
        appleBtn.snp.makeConstraints { (make) in
            make.left.right.equalTo(kakaoBtn)
            make.top.equalTo(kakaoBtn.snp.bottom).offset(16)
            make.height.equalTo(40)
        }
        
        kakaoBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(31)
            make.right.equalToSuperview().offset(-32)
            make.top.equalTo(lottie.snp.bottom).offset(30)
            make.height.equalTo(40)
        }
        
        kakaoLabel.snp.makeConstraints { (make) in
            make.center.equalTo(kakaoBtn)
        }
        
        kakaoImg.snp.makeConstraints { (make) in
            make.centerY.equalTo(kakaoLabel)
            make.right.equalTo(kakaoLabel.snp.left).offset(-6)
            make.width.height.equalTo(16)
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
