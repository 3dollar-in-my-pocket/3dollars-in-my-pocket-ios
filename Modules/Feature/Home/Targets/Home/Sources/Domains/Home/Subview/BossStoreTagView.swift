import UIKit

import Common
import DesignSystem

final class BossStoreTagView: BaseView {
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = Colors.gray80.color
        
        return view
    }()
    
    private let checkImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Icons.check.image.withTintColor(Colors.mainPink.color)
        
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 12)
        label.textColor = Colors.mainPink.color
        label.text = Strings.homeBossStoreTag
        
        return label
    }()
    
    override func setup() {
        addSubViews([
            containerView,
            checkImage,
            titleLabel
        ])
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalTo(titleLabel.snp.trailing).offset(8)
            $0.height.equalTo(24)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        checkImage.snp.makeConstraints {
            $0.leading.equalTo(containerView).offset(8)
            $0.centerY.equalTo(containerView)
            $0.size.equalTo(16)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(checkImage.snp.trailing).offset(4)
            $0.centerY.equalTo(containerView)
        }
        
        snp.makeConstraints {
            $0.leading.equalTo(containerView).priority(.high)
            $0.trailing.equalTo(containerView).priority(.high)
        }
    }
}
