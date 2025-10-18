import UIKit

import Common
import DesignSystem

final class HomeListCellTagView: BaseView {
    enum ViewType {
        /// 최근 방문
        case recentVisit(count: Int)
        
        /// 사장님 직영
        case boss
        
        case coupon
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var leftImage: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        return imageView
    }()
    
    private let titleLabel = UILabel()
    
    override func setup() {
        super.setup()
        
        setupUI()
    }
    
    private func setupUI() {
        addSubViews([
            containerView,
            leftImage,
            titleLabel
        ])
        
        containerView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalTo(titleLabel.snp.right).offset(8)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        snp.makeConstraints {
            $0.edges.equalTo(containerView).priority(.high)
        }
    }
    
    func prepareForReuse() {
        titleLabel.snp.removeConstraints()
        leftImage.snp.removeConstraints()
    }
    
    func bind(type: ViewType) {
        switch type {
        case .recentVisit(let count):
            containerView.backgroundColor = DesignSystemAsset.Colors.gray10.color
            leftImage.isHidden = true
            titleLabel.font = DesignSystemFontFamily.Pretendard.medium.font(size: 12)
            titleLabel.textColor = DesignSystemAsset.Colors.gray70.color
            
            let string = "최근 방문 \(count)명"
            let boldStringRange = NSString(string: string).range(of: "\(count)명")
            let attributedString = NSMutableAttributedString(string: string)
            attributedString.addAttributes([.font: DesignSystemFontFamily.Pretendard.bold.font(size: 12)], range: boldStringRange)
            titleLabel.attributedText = attributedString
            titleLabel.snp.makeConstraints {
                $0.left.equalTo(containerView).offset(8)
                $0.centerY.equalTo(containerView)
            }
            
        case .boss:
            containerView.backgroundColor = DesignSystemAsset.Colors.pink100.color
            leftImage.isHidden = false
            leftImage.image = DesignSystemAsset.Icons.check.image.withTintColor(DesignSystemAsset.Colors.mainPink.color)
            titleLabel.font = DesignSystemFontFamily.Pretendard.bold.font(size: 12)
            titleLabel.text = "사장님 직영"
            titleLabel.textColor = DesignSystemAsset.Colors.mainPink.color
            
            leftImage.snp.makeConstraints {
                $0.width.height.equalTo(16)
                $0.left.equalTo(containerView).offset(8)
                $0.centerY.equalToSuperview()
            }
            
            titleLabel.snp.makeConstraints {
                $0.left.equalTo(leftImage.snp.right).offset(4)
                $0.centerY.equalTo(containerView)
            }
        case .coupon:
            containerView.backgroundColor = DesignSystemAsset.Colors.mainPink.color
            leftImage.image = DesignSystemAsset.Icons.couponLine.image.withTintColor(DesignSystemAsset.Colors.systemWhite.color)
            leftImage.isHidden = false
            titleLabel.font = DesignSystemFontFamily.Pretendard.medium.font(size: 12)
            titleLabel.text = "쿠폰!"
            titleLabel.textColor = DesignSystemAsset.Colors.systemWhite.color
            
            leftImage.snp.makeConstraints {
                $0.width.height.equalTo(16)
                $0.left.equalTo(containerView).offset(8)
                $0.centerY.equalToSuperview()
            }
            
            titleLabel.snp.makeConstraints {
                $0.left.equalTo(leftImage.snp.right).offset(4)
                $0.centerY.equalTo(containerView)
            }
        }
    }
}
