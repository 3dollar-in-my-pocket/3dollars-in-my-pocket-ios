import UIKit

import Common
import DesignSystem

final class SigninBottomSheetView: BaseView {
    let backgroundButton = UIButton()
    
    private let containerView: UIView = {
        let view = UIView()
        
        view.layer.cornerRadius = 24
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.masksToBounds = true
        view.backgroundColor = Colors.gray90.color
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        label.text = Strings.signinBottomSheetTitle
        label.textColor = Colors.systemWhite.color
        label.font = Fonts.semiBold.font(size: 20)
        label.numberOfLines = 2
        label.setLineHeight(lineHeight: 28)
        return label
    }()
    
    let closeButton: UIButton = {
        let button = UIButton()
        
        button.setImage(Assets.icClose.image, for: .normal)
        button.adjustsImageWhenHighlighted = false
        button.tintColor = Colors.systemWhite.color
        return button
    }()
    
    let kakaoButton = SigninButton(type: .kakao)
    
    let appleButton = SigninButton(type: .apple)
    
    override func setup() {
        addSubViews([
            backgroundButton,
            containerView,
            titleLabel,
            closeButton,
            kakaoButton,
            appleButton
        ])
    }
    
    override func bindConstraints() {
        backgroundButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalTo(containerView.snp.top)
        }
        
        appleButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-24)
            $0.height.equalTo(48)
        }
        
        kakaoButton.snp.makeConstraints {
            $0.leading.equalTo(appleButton)
            $0.trailing.equalTo(appleButton)
            $0.bottom.equalTo(appleButton.snp.top).offset(-12)
            $0.height.equalTo(48)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalTo(kakaoButton.snp.top).offset(-40)
        }
        
        closeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(kakaoButton.snp.top).offset(-72)
            $0.size.equalTo(24)
        }
        
        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(closeButton).offset(-26)
        }
    }
}
