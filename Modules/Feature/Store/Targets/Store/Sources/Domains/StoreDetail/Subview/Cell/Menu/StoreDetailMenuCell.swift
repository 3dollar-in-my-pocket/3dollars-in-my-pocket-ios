import UIKit

import Common
import DesignSystem
import Model

final class StoreDetailMenuCell: BaseCollectionViewCell {
    enum Layout {
        static let topBottomPadding: CGFloat = 32
        static let spaceBetweenCell: CGFloat = 12
        static let moreButtonHeight: CGFloat = 50
        static let moreButtonShowCount = 6
        
        static func calculateHeight(menus: [StoreDetailMenu], isShowAll: Bool) -> CGFloat {
            var height: CGFloat = 0
            let categories = Array(Set(menus.map { $0.category }))
            var stackItemCount = 0
            
            for category in categories {
                height += StoreDetailMenuCategoryStackItemView.Layout.height
                stackItemCount += 1
                
                let categoryMenu = menus.filter { $0.category == category && $0.isValid }
                
                if categoryMenu.count > 0 {
                    height += CGFloat(categoryMenu.count) * StoreDetailMenuStackItemView.Layout.height
                    height += CGFloat(categoryMenu.count - 1) * 8
                    stackItemCount += categoryMenu.count
                }
                height += 8
                
                if (stackItemCount >= moreButtonShowCount) && !isShowAll {
                    height += moreButtonHeight
                    break
                }
            }
            
            return height + topBottomPadding + spaceBetweenCell
        }
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray0.color
        view.layer.cornerRadius = 20
        
        return view
    }()
    
    private let menuStackView = StoreDetailMenuStackView()
    
    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray20.color
        
        return view
    }()
    
    private let moreButton: UIButton = {
        let button = UIButton()
        button.setTitle("메뉴 더 보기", for: .normal)
        button.setTitleColor(Colors.gray60.color, for: .normal)
        button.titleLabel?.font = Fonts.medium.font(size: 12)
        
        return button
    }()
    
    override func setup() {
        contentView.addSubViews([
            containerView,
            menuStackView,
            divider,
            moreButton
        ])
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalToSuperview().offset(12)
            $0.right.equalToSuperview()
            $0.bottom.equalTo(menuStackView).offset(16)
        }
        
        menuStackView.snp.makeConstraints {
            $0.left.equalTo(containerView).offset(16)
            $0.top.equalTo(containerView).offset(16)
            $0.right.equalTo(containerView).offset(-16)
        }
    }
    
    func bind(_ viewModel: StoreDetailMenuCellViewModel) {
        menuStackView.bind(viewModel.output.menus, isShowAll: viewModel.output.isShowAll)
        
        if (menuStackView.subviews.count >= Layout.moreButtonShowCount) && !viewModel.output.isShowAll {
            setupMoreButton()
        }
    }
    
    private func setupMoreButton() {
        contentView.addSubViews([
            divider,
            moreButton
        ])
        
        containerView.snp.remakeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalToSuperview().offset(12)
            $0.right.equalToSuperview()
            $0.bottom.equalTo(moreButton)
        }
        
        divider.snp.makeConstraints {
            $0.left.equalTo(containerView).offset(24)
            $0.right.equalTo(containerView).offset(-24)
            $0.height.equalTo(1)
            $0.top.equalTo(menuStackView.snp.bottom).offset(16)
        }
        
        moreButton.snp.makeConstraints {
            $0.left.equalTo(divider)
            $0.right.equalTo(divider)
            $0.top.equalTo(divider.snp.bottom)
            $0.height.equalTo(Layout.moreButtonHeight)
        }
    }
}
