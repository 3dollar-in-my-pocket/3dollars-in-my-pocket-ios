import UIKit

import Common
import DesignSystem
import Then

final class SigninView: BaseView {
    private let logoImage = UIImageView(image: MembershipAsset.imageSplash.image)
    
    let kakaoButton = SigninButton(type: .kakao)
    
    let appleButton = SigninButton(type: .apple)
    
    let signinNonMemberButton = UIButton().then {
        $0.setTitle(MembershipStrings.signinNonMember, for: .normal)
        $0.setTitleColor(DesignSystemAsset.Colors.systemWhite.color, for: .normal)
        $0.titleLabel?.font = DesignSystemFontFamily.Pretendard.regular.font(size: 14)
    }
    
    override func setup() {
        backgroundColor = DesignSystemAsset.Colors.mainPink.color
        addSubViews([
            logoImage,
            kakaoButton,
            appleButton,
            signinNonMemberButton
        ])
    }
    
    override func bindConstraints() {
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
        
        signinNonMemberButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(appleButton.snp.bottom).offset(20)
        }
    }
}
