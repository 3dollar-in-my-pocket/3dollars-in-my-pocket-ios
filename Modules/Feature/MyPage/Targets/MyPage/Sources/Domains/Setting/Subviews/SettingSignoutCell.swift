import UIKit

import Common

final class SettingSignoutCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: UIUtils.windowBounds.width, height: 34)
    }
    
    let signoutButton: UIButton = {
        let button = UIButton()
        
        let image = Icons.infomation.image
            .resizeImage(scaledTo: 16)
            .withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = Colors.gray70.color
        button.setTitle(Strings.Setting.signout, for: .normal)
        button.titleLabel?.font = Fonts.medium.font(size: 12)
        button.setTitleColor(Colors.gray70.color, for: .normal)
        button.titleEdgeInsets = .init(top: 0, left: 4, bottom: 0, right: -4)
        return button
    }()
    
    let logoutButton: UIButton = {
        let button = UIButton()
        
        button.setTitle(Strings.Setting.logout, for: .normal)
        button.titleLabel?.font = Fonts.medium.font(size: 12)
        button.setTitleColor(Colors.gray70.color, for: .normal)
        return button
    }()
    
    override func setup() {
        contentView.addSubViews([
            signoutButton,
            logoutButton
        ])
    }
    
    override func bindConstraints() {
        signoutButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(16)
        }
        
        logoutButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(signoutButton)
        }
    }
}
