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
    
    let kakaoBtn = KOLoginButton()
    
    let appleBtn = ASAuthorizationAppleIDButton()
    
    
    override func setup() {
        backgroundColor = UIColor.init(r: 28, g: 28, b: 28)
        addSubViews(lottie, kakaoBtn, appleBtn)
    }
    
    override func bindConstraints() {
        
        lottie.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(70)
            make.height.equalTo(350)
        }
        
        appleBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-100)
            make.height.equalTo(48)
        }
        
        kakaoBtn.snp.makeConstraints { (make) in
            make.left.right.equalTo(appleBtn)
            make.height.equalTo(48)
            make.bottom.equalTo(appleBtn.snp.top).offset(-20)
        }
    }
}
