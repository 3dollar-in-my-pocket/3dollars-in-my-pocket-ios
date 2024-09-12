import UIKit

import Common
import Model
import DesignSystem

final class HomeListHeaderCell: BaseCollectionViewReusableView {
    enum Layout {
        static let size: CGSize = CGSize(width: UIScreen.main.bounds.width, height: Layout.height)
        static let height: CGFloat = 76
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = DesignSystemAsset.Colors.systemBlack.color
        label.font = DesignSystemFontFamily.Pretendard.semiBold.font(size: 20)
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()
    
    let isOnlyCertifiedButton: UIButton = {
        let button = UIButton()
        button.setTitle(HomeStrings.homeListIsOnlyCertified, for: .normal)
        button.setTitleColor(DesignSystemAsset.Colors.gray60.color, for: .normal)
        button.setImage(DesignSystemAsset.Icons.checkBoxOff.image, for: .normal)
        button.setImage(DesignSystemAsset.Icons.checkBoxOn.image, for: .selected)
        button.titleEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: -4)
        button.contentEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 4)
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.regular.font(size: 14)
        return button
    }()
    
    override func setup() {
        setupUI()
    }
    
    private func setupUI() {
        addSubViews([
            titleLabel,
            isOnlyCertifiedButton
        ])
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(20)
        }
        
        isOnlyCertifiedButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().offset(-20)
        }
    }
    
    func bind(category: StoreFoodCategoryResponse?) {
        if let category {
            titleLabel.text = category.description
        } else {
            titleLabel.text = HomeStrings.homeListHeaderTotal
        }
    }
}
