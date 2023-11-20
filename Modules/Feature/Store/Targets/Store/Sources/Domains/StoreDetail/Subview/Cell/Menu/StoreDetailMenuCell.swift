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
        static let space: CGFloat = 8
        
        static func calculateHeight(menus: [StoreDetailMenu], isShowAll: Bool) -> CGFloat {
            var height: CGFloat = 0
            var menuCount = 0
            let categories = menus.map { $0.category }.unique
            
            for category in categories {
                height += StoreDetailMenuCategoryStackItemView.Layout.height
                height += space
                
                let categoryMenus = menus.filter { $0.category == category && $0.isValid }
                
                for _ in categoryMenus {
                    height += StoreDetailMenuStackItemView.Layout.height
                    height += space
                    menuCount += 1
                    
                    if menuCount > moreButtonShowCount && !isShowAll {
                        break
                    }
                }
            }
            
            if validMenuCount(menus: menus) > moreButtonShowCount && !isShowAll {
                height += moreButtonHeight
            }
            
            return height + topBottomPadding + spaceBetweenCell
        }
        
        static func validMenuCount(menus: [StoreDetailMenu]) -> Int {
            var count = 0
            
            let categories = menus.map { $0.category }.unique
            
            for category in categories {
                let menuCount = menus.filter { $0.category == category && $0.isValid }.count
                
                count += menuCount
            }
            
            return count
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
        button.setTitle(Strings.StoreDetail.Menu.more, for: .normal)
        button.setTitleColor(Colors.gray60.color, for: .normal)
        button.titleLabel?.font = Fonts.medium.font(size: 12)
        
        return button
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        menuStackView.prepareForReuse()
        cancellables.removeAll()
    }
    
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
        
        let isShowMoreButton = StoreDetailMenuCell.Layout.validMenuCount(menus: viewModel.output.menus) > StoreDetailMenuCell.Layout.moreButtonShowCount && !viewModel.output.isShowAll
        setupMoreButton(isShowMoreButton: isShowMoreButton)
        
        moreButton.controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapMore)
            .store(in: &cancellables)
    }
    
    private func clearMoreButton() {
        divider.removeFromSuperview()
        moreButton.removeFromSuperview()
    }
    
    private func setupMoreButton(isShowMoreButton: Bool) {
        if isShowMoreButton {
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
        } else {
            divider.removeFromSuperview()
            moreButton.removeFromSuperview()
            
            containerView.snp.remakeConstraints {
                $0.left.equalToSuperview()
                $0.top.equalToSuperview().offset(12)
                $0.right.equalToSuperview()
                $0.bottom.equalTo(menuStackView).offset(16)
            }
        }
    }
}
