import UIKit

import Common
import DesignSystem
import Model

final class MarkerPopupView: BaseView {
    let backgroundButton = UIButton()
    
    private let containerView = UIView().then {
        $0.layer.cornerRadius = 30
        $0.backgroundColor = Colors.systemWhite.color
        $0.layer.masksToBounds = true
    }
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    let closeButton = UIButton().then {
        $0.setImage(Icons.deleteX.image, for: .normal)
    }
    
    private let titleLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 18)
        $0.textColor = Colors.gray100.color
        $0.textAlignment = .center
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = Fonts.regular.font(size: 16)
        $0.textColor = Colors.gray50.color
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    let bottomButton = UIButton().then {
        $0.layer.cornerRadius = 24
        $0.backgroundColor = Colors.mainRed.color
        $0.titleLabel?.font = Fonts.bold.font(size: 16)
    }
    
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
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-22)
            $0.top.equalTo(imageView)
        }
        
        bottomButton.snp.makeConstraints {
            $0.left.equalTo(containerView).offset(24)
            $0.right.equalTo(containerView).offset(-24)
            $0.bottom.equalTo(containerView).offset(-24)
            $0.height.equalTo(48)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.left.equalTo(containerView).offset(24)
            $0.right.equalTo(containerView).offset(-24)
            $0.bottom.equalTo(bottomButton.snp.top).offset(-24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.equalTo(containerView)
            $0.right.equalTo(containerView)
            $0.bottom.equalTo(descriptionLabel.snp.top).offset(-4)
        }
        
        imageView.snp.makeConstraints {
            $0.left.equalTo(containerView)
            $0.right.equalTo(containerView)
            $0.bottom.equalTo(titleLabel.snp.top).offset(-24)
            $0.height.equalTo(160)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalTo(imageView).offset(24)
            $0.right.equalTo(imageView).offset(-24)
            $0.width.equalTo(24)
            $0.height.equalTo(24)
        }
    }
    
    func bind(advertisement: Advertisement) {
        imageView.setImage(urlString: advertisement.imageUrl)
        titleLabel.text = advertisement.title
        descriptionLabel.text = advertisement.subTitle
        bottomButton.setTitle(advertisement.extraContent, for: .normal)
    }
}
