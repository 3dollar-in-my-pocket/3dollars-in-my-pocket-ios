import UIKit

import Common
import SnapKit

final class SigninView: BaseView {
    let logoButton: UIButton = {
        let button = UIButton()
        
        button.setImage(Assets.imageSplash.image, for: .normal)
        button.contentMode = .scaleAspectFit
        button.adjustsImageWhenHighlighted = false
        return button
    }()
    
    let kakaoButton = SigninButton(type: .kakao)
    
    let appleButton = SigninButton(type: .apple)
    
    let signinAnonymousButton: UIButton = {
        let button = UIButton()
        
        button.setTitle(Strings.signinAnonymous, for: .normal)
        button.setTitleColor(Colors.systemWhite.color, for: .normal)
        button.titleLabel?.font = Fonts.regular.font(size: 14)
        return button
    }()
    
    override func setup() {
        backgroundColor = Colors.mainPink.color
        addSubViews([
            logoButton,
            kakaoButton,
            appleButton,
            signinAnonymousButton
        ])
    }
    
    override func bindConstraints() {
        logoButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(32)
            $0.right.equalToSuperview().offset(-32)
            $0.bottom.equalTo(kakaoButton.snp.top).offset(-72)
        }
        
        kakaoButton.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(48)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(48)
        }
        
        appleButton.snp.makeConstraints {
            $0.left.equalTo(kakaoButton)
            $0.right.equalTo(kakaoButton)
            $0.top.equalTo(kakaoButton.snp.bottom).offset(12)
            $0.height.equalTo(48)
        }
        
        signinAnonymousButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(appleButton.snp.bottom).offset(20)
        }
    }
}
