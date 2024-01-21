import UIKit

import Common
import DesignSystem

final class TeamInfoView: BaseView {
    let backButton: UIButton = {
        let button = UIButton()
        let image = Icons.arrowLeft.image.withTintColor(Colors.systemWhite.color)
        
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        label.font = Fonts.medium.font(size: 16)
        label.textColor = Colors.systemWhite.color
        label.text = Strings.TeamInfo.title
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .vertical
        stackView.spacing = 40
        stackView.alignment = .center
        return stackView
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.image = Images.imageLogo.image
        return imageView
    }()
    
    let teamInfoGroupView = TeamInfoGroupView()
    
    let instagramButton: UIButton = {
        let button = UIButton()
        
        button.setTitle(Strings.TeamInfo.insta, for: .normal)
        button.setTitleColor(Colors.systemWhite.color, for: .normal)
        button.titleLabel?.font = Fonts.medium.font(size: 12)
        
        let image = Images.iconInsta.image.resizeImage(scaledTo: 20).withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = Colors.systemWhite.color
        button.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 4)
        button.titleEdgeInsets = .init(top: 0, left: 4, bottom: 0, right: -4)
        button.adjustsImageWhenHighlighted = false
        return button
    }()
    
    override func setup() {
        backgroundColor = Colors.mainPink.color
        
        stackView.addArrangedSubview(logoImageView)
        stackView.addArrangedSubview(teamInfoGroupView)
        
        addSubViews([
            backButton,
            titleLabel,
            stackView,
            instagramButton
        ])
    }
    
    override func bindConstraints() {
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalTo(safeAreaLayoutGuide).offset(16)
            $0.size.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton)
        }
        
        logoImageView.snp.makeConstraints {
            $0.height.equalTo(160)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(82)
            $0.leading.equalToSuperview().offset(48)
            $0.trailing.equalToSuperview().offset(-48)
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }
        
        logoImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(backButton.snp.bottom).offset(82)
        }
        
        instagramButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-24)
        }
    }
}
