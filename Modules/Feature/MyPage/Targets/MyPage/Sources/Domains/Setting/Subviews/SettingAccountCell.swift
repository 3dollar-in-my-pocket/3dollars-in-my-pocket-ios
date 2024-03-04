import UIKit

import Common
import DesignSystem
import Model

final class SettingAccountCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: UIUtils.windowBounds.width, height: 104)
    }
    
    private let socialLogo = UIImageView()
    
    private let socialTypeLabel: UILabel = {
        let label = UILabel()
        
        label.font = Fonts.medium.font(size: 10)
        label.textColor = Colors.gray50.color
        
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        
        label.font = Fonts.bold.font(size: 24)
        label.textColor = Colors.systemWhite.color
        return label
    }()
    
    let editNameButton: UIButton = {
        let button = UIButton()
        let icon = Icons.writeSolid.image.withTintColor(Colors.mainPink.color)
        
        button.setImage(icon, for: .normal)
        return button
    }()
    
    override func setup() {
        contentView.addSubViews([
            socialLogo,
            socialTypeLabel,
            nameLabel,
            editNameButton
        ])
    }
    
    override func bindConstraints() {
        socialLogo.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(20)
            $0.size.equalTo(16)
        }
        
        socialTypeLabel.snp.makeConstraints {
            $0.leading.equalTo(socialLogo.snp.trailing).offset(4)
            $0.centerY.equalTo(socialLogo)
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(socialLogo.snp.bottom).offset(8)
            $0.bottom.equalToSuperview().offset(-28)
        }
        
        editNameButton.snp.makeConstraints {
            $0.leading.equalTo(nameLabel.snp.trailing).offset(8)
            $0.centerY.equalTo(nameLabel)
            $0.size.equalTo(16)
        }
    }
    
    func bind(name: String, socialType: SocialType) {
        nameLabel.text = name
        socialLogo.image = socialType.image
        socialTypeLabel.text = socialType.title
    }
}


private extension SocialType {
    var image: UIImage {
        switch self {
        case .apple:
            return Images.iconApple.image
        case .kakao:
            return Images.iconKakao.image
        case .google, .unknown:
            return Images.iconGoogle.image
        }
    }
    
    var title: String {
        switch self {
        case .apple:
            return Strings.Setting.appleUser
        case .kakao:
            return Strings.Setting.kakaoUser
        case .google:
            return Strings.Setting.googleUser
        case .unknown:
            return ""
        }
    }
}
