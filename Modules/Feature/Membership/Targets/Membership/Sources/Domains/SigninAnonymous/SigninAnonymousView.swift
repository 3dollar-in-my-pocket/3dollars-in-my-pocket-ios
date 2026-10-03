import UIKit
import AuthenticationServices

import Common
import DesignSystem

final class SigninAnonymousView: BaseView {
    enum Layout {
        static let logoSize: CGFloat = 254
    }

    let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(Icons.close.image.withTintColor(Colors.gray100.color), for: .normal)
        
        return button
    }()
    
    private let logoImage: UIImageView = {
        let imageView = UIImageView(image: Assets.imageSplash.image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let kakaoButton = SigninButton(type: .kakao)
    
    let appleButton = SigninButton(type: .apple)
    
    private let anonymousLabel: UILabel = {
        let anonymousLabel = UILabel()
        anonymousLabel.font = Fonts.regular.font(size: 14)
        anonymousLabel.textColor = Colors.gray100.color
        anonymousLabel.numberOfLines = 0
        anonymousLabel.text = Strings.signinAnonymousDescription
        anonymousLabel.textAlignment = .center
        return anonymousLabel
    }()
    
    override func setup() {
        backgroundColor = Assets.signinBackground.color
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
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalTo(safeAreaLayoutGuide).offset(16)
            $0.width.equalTo(24)
            $0.height.equalTo(24)
        }
        
        logoImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.size.equalTo(Layout.logoSize)
            $0.bottom.equalTo(kakaoButton.snp.top).offset(-48)
        }
        
        kakaoButton.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(48)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(48)
        }
        
        appleButton.snp.makeConstraints {
            $0.leading.equalTo(kakaoButton)
            $0.trailing.equalTo(kakaoButton)
            $0.top.equalTo(kakaoButton.snp.bottom).offset(12)
            $0.height.equalTo(48)
        }
        
        anonymousLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(appleButton.snp.bottom).offset(36)
        }
    }
}
