import UIKit
import AuthenticationServices

import Common
import DesignSystem
import Then

final class SigninAnonymousView: BaseView {
    let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(Icons.close.image.withTintColor(Colors.systemWhite.color), for: .normal)
        
        return button
    }()
    
    private let logoImage = UIImageView(image: Assets.imageSplash.image)
    
    let kakaoButton = SigninButton(type: .kakao)
    
    let appleButton = SigninButton(type: .apple)
    
    private let anonymousLabel = UILabel().then {
        $0.font = Fonts.regular.font(size: 14)
        $0.textColor = Colors.systemWhite.color
        $0.numberOfLines = 0
        $0.text = Strings.signinAnonymousDescription
        $0.textAlignment = .center
    }
    
    override func setup() {
        backgroundColor = Colors.mainPink.color
        addSubViews([
            closeButton,
            logoImage,
            kakaoButton,
            appleButton,
            anonymousLabel
        ])
    }
    
    override func bindConstraints() {
        closeButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-16)
            $0.top.equalTo(safeAreaLayoutGuide).offset(16)
            $0.width.equalTo(24)
            $0.height.equalTo(24)
        }
        
        logoImage.snp.makeConstraints {
            $0.left.equalToSuperview().offset(32)
            $0.right.equalToSuperview().offset(-32)
            $0.bottom.equalTo(kakaoButton.snp.top).offset(-48)
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
        
        anonymousLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(appleButton.snp.bottom).offset(36)
        }
    }
}
