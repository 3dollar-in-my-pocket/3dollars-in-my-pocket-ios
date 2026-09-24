import UIKit

import Common
import DesignSystem
import Model

final class MarkerPopupView: BaseView {
    let backgroundButton = UIButton()
    
    private let containerView: UIView = {
        let containerView = UIView()
        containerView.layer.cornerRadius = 30
        containerView.backgroundColor = Colors.systemWhite.color
        containerView.layer.masksToBounds = true
        return containerView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let closeButton: UIButton = {
        let closeButton = UIButton()
        closeButton.setImage(Icons.deleteX.image, for: .normal)
        return closeButton
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = Fonts.bold.font(size: 18)
        titleLabel.textColor = Colors.gray100.color
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    private let descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.font = Fonts.regular.font(size: 16)
        descriptionLabel.textColor = Colors.gray50.color
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        return descriptionLabel
    }()
    
    let bottomButton: UIButton = {
        let bottomButton = UIButton()
        bottomButton.layer.cornerRadius = 24
        bottomButton.backgroundColor = Colors.mainRed.color
        bottomButton.titleLabel?.font = Fonts.bold.font(size: 16)
        return bottomButton
    }()
    
    override func setup() {
        containerView.addSubViews([
            imageView,
            titleLabel,
            descriptionLabel,
            bottomButton,
            closeButton
        ])
        addSubViews([
            backgroundButton,
            containerView
        ])
    }
    
    override func bindConstraints() {
        backgroundButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-22)
            $0.top.equalTo(imageView)
        }
        
        bottomButton.snp.makeConstraints {
            $0.leading.equalTo(containerView).offset(24)
            $0.trailing.equalTo(containerView).offset(-24)
            $0.bottom.equalTo(containerView).offset(-24)
            $0.height.equalTo(48)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.leading.equalTo(containerView).offset(24)
            $0.trailing.equalTo(containerView).offset(-24)
            $0.bottom.equalTo(bottomButton.snp.top).offset(-24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(containerView)
            $0.trailing.equalTo(containerView)
            $0.bottom.equalTo(descriptionLabel.snp.top).offset(-4)
        }
        
        imageView.snp.makeConstraints {
            $0.leading.equalTo(containerView)
            $0.trailing.equalTo(containerView)
            $0.bottom.equalTo(titleLabel.snp.top).offset(-24)
            $0.height.equalTo(160)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalTo(imageView).offset(24)
            $0.trailing.equalTo(imageView).offset(-24)
            $0.width.equalTo(24)
            $0.height.equalTo(24)
        }
    }
    
    func bind(advertisement: AdvertisementResponse) {
        imageView.setImage(urlString: advertisement.image?.url)
        
        titleLabel.text = advertisement.title?.content
        if let titleColor = advertisement.title?.fontColor {
            titleLabel.textColor = UIColor(hex: titleColor)
        }
        
        descriptionLabel.text = advertisement.subTitle?.content
        if let descriptionColor = advertisement.subTitle?.fontColor {
            descriptionLabel.textColor = UIColor(hex: descriptionColor)
        }
        
        bottomButton.setTitle(advertisement.extra?.content, for: .normal)
        if let buttonTitleColor = advertisement.extra?.fontColor {
            bottomButton.setTitleColor(UIColor(hex: buttonTitleColor), for: .normal)
        }
    }
}
