import UIKit

import Common
import DesignSystem

final class TeamInfoAdButton: BaseView {
    enum Layout {
        static let size = CGSize(width: 136, height: 66)
    }
    
    let button = UIButton()
    
    private let containerView: UIView = {
        let view = UIView()
        
        view.backgroundColor = Colors.systemWhite.color
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = Colors.mainPink.color
        label.font = Fonts.medium.font(size: 10)
        label.text = "커피☕️ 사주기"
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.alignment = .center
        return stackView
    }()
    
    private let adLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = Colors.gray100.color
        label.font = Fonts.bold.font(size: 16)
        label.text = "광고 보기"
        return label
    }()
    
    private let arrowRightImage: UIImageView = {
        let imageView = UIImageView()
        let image = Icons.arrowRight.image.withRenderingMode(.alwaysTemplate).resizeImage(scaledTo: 12)
        
        imageView.image = image
        imageView.tintColor = Colors.gray40.color
        return imageView
    }()
    
    override func setup() {
        stackView.addArrangedSubview(adLabel)
        stackView.addArrangedSubview(arrowRightImage)
        addSubViews([
            containerView,
            titleLabel,
            stackView,
            button
        ])
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.size.equalTo(Layout.size)
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalTo(containerView)
            $0.top.equalTo(containerView).offset(12)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
        }
        
        button.snp.makeConstraints {
            $0.edges.equalTo(containerView)
        }
        
        snp.makeConstraints {
            $0.edges.equalTo(containerView).priority(.high)
        }
    }
}
