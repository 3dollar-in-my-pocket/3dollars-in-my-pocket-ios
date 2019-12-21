import UIKit
import Then
import SnapKit
import KakaoOpenSDK
import AuthenticationServices

class SignInView: BaseView {
    
    let kakaoBtn = KOLoginButton()
    
    let naverBtn = UIButton().then {
        $0.setTitle("네이버 아이디로 로그인", for: .normal)
        $0.backgroundColor = .green
    }
    
    let appleBtn = ASAuthorizationAppleIDButton()
    
    override func setup() {
        backgroundColor = .white
        addSubViews(kakaoBtn, naverBtn, appleBtn)
    }
    
    override func bindConstraints() {
        kakaoBtn.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(48)
        }
        
        naverBtn.snp.makeConstraints { (make) in
            make.left.right.equalTo(kakaoBtn)
            make.top.equalTo(kakaoBtn.snp.bottom).offset(20)
            make.height.equalTo(48)
        }
        
        appleBtn.snp.makeConstraints { (make) in
            make.left.right.equalTo(kakaoBtn)
            make.top.equalTo(naverBtn.snp.bottom).offset(20)
            make.height.equalTo(48)
        }
    }
}
