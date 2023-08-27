import UIKit

import Common
import DesignSystem

final class HomeListCellTagView: BaseView {
    enum ViewType {
        /// 최근 방문
        case recentVisit(count: Int)
        
        /// 사장님 직영
        case boss
    }
    
    private let containerView = UIView().then {
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
    }
    
    private lazy var checkImage = UIImageView(image: DesignSystemAsset.Icons.check.image.withTintColor(DesignSystemAsset.Colors.mainPink.color)).then {
        $0.isHidden = true
    }
    
    private let titleLabel = UILabel()
    
    override func setup() {
        super.setup()
        
        addSubViews([
            containerView,
            checkImage,
            titleLabel
        ])
    }
    
    override func bindConstraints() {
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
        checkImage.snp.removeConstraints()
    }
    
    func bind(type: ViewType) {
        switch type {
        case .recentVisit(let count):
            containerView.backgroundColor = DesignSystemAsset.Colors.gray10.color
            checkImage.isHidden = true
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
            checkImage.isHidden = false
            titleLabel.font = DesignSystemFontFamily.Pretendard.bold.font(size: 12)
            titleLabel.text = "사장님 직영"
            titleLabel.textColor = DesignSystemAsset.Colors.mainPink.color
            
            checkImage.snp.makeConstraints {
                $0.width.height.equalTo(16)
                $0.left.equalTo(containerView).offset(8)
                $0.centerY.equalToSuperview()
            }
            
            titleLabel.snp.makeConstraints {
                $0.left.equalTo(checkImage.snp.right).offset(4)
                $0.centerY.equalTo(containerView)
            }
        }
    }
}
