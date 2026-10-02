import UIKit

import Common
import SnapKit

final class SigninView: BaseView {
    enum Layout {
        static let logoSize: CGFloat = 254
        static let logoMinimumBottomSpacing: CGFloat = 24
        static let buttonHeight: CGFloat = 48
        static let buttonSpacing: CGFloat = 12
        static let anonymousTopSpacing: CGFloat = 20
        static let anonymousHeight: CGFloat = 20
        static let bottomInset: CGFloat = 51
    }

    let logoButton: UIButton = {
        let button = UIButton()
        
        button.setImage(Assets.imageSplash.image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.adjustsImageWhenHighlighted = false
        return button
    }()
    
    let kakaoButton = SigninButton(type: .kakao)
    
    let appleButton = SigninButton(type: .apple)
    
    let signinAnonymousButton: UIButton = {
        let button = UIButton()
        
        button.setTitle(Strings.signinAnonymous, for: .normal)
        button.setTitleColor(Colors.gray100.color, for: .normal)
        button.titleLabel?.font = Fonts.regular.font(size: 14)
        return button
    }()
    
    private let logoAreaGuide = UILayoutGuide()

    override func setup() {
        backgroundColor = Assets.signinBackground.color
        addLayoutGuide(logoAreaGuide)
        addSubViews([
            logoButton,
            kakaoButton,
            appleButton,
            signinAnonymousButton
        ])
    }
    
    override func bindConstraints() {
        logoAreaGuide.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.bottom.equalTo(kakaoButton.snp.top)
            $0.leading.trailing.equalToSuperview()
        }

        logoButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.size.equalTo(Layout.logoSize)
            $0.centerY.equalTo(logoAreaGuide).priority(.high)
            $0.bottom.lessThanOrEqualTo(kakaoButton.snp.top).offset(-Layout.logoMinimumBottomSpacing)
        }
        
        kakaoButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(Layout.buttonHeight)
        }
        
        appleButton.snp.makeConstraints {
            $0.leading.equalTo(kakaoButton)
            $0.trailing.equalTo(kakaoButton)
            $0.top.equalTo(kakaoButton.snp.bottom).offset(Layout.buttonSpacing)
            $0.height.equalTo(Layout.buttonHeight)
        }
        
        signinAnonymousButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(appleButton.snp.bottom).offset(Layout.anonymousTopSpacing)
            $0.height.equalTo(Layout.anonymousHeight)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-Layout.bottomInset)
        }
    }
}
