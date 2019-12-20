import UIKit
import Then
import SnapKit
import KakaoOpenSDK

class SignInView: BaseView {
    
    let kakaoBtn = KOLoginButton()
    
    
    override func setup() {
        backgroundColor = .white
        addSubViews(kakaoBtn)
    }
    
    override func bindConstraints() {
        kakaoBtn.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(48)
        }
    }
}
