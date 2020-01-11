import UIKit
import KakaoOpenSDK
import SnapKit
import Then
import AuthenticationServices

class SignInView: BaseView {
    
    let kakaoBtn = KOLoginButton()
    
    let appleBtn = ASAuthorizationAppleIDButton()
    
    
    override func setup() {
        backgroundColor = .white
        addSubViews(kakaoBtn, appleBtn)
    }
    
    override func bindConstraints() {
        kakaoBtn.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(48)
        }
        
        appleBtn.snp.makeConstraints { (make) in
            make.left.right.equalTo(kakaoBtn)
            make.top.equalTo(kakaoBtn.snp.bottom).offset(20)
            make.height.equalTo(48)
        }
    }
}
