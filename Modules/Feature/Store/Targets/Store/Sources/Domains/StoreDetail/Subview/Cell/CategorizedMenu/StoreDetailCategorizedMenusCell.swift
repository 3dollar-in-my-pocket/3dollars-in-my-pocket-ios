import UIKit

import Common
import DesignSystem
import Model

final class StoreDetailCategorizedMenusCell: BaseCollectionViewCell {
    enum Layout {
        static let topPadding: CGFloat = 12
        static let spaceBetweenCategory: CGFloat = 12
        static let spaceBetweenMenu: CGFloat = 8
        
        static let moreButtonHeight: CGFloat = 50
        static let moreButtonShowCount = 6
        
        static func calculateHeight(data: StoreCategorizedMenusSectionResponse, isShowAll: Bool) -> CGFloat {
            var height: CGFloat = 0
            var menuCount = 0
            
            for categorizedMenu in data.menus {
                height += StoreDetailMenuCategoryItemView.Layout.height
                height += spaceBetweenMenu
                
                for _ in categorizedMenu.menus {
                    height += StoreDetailMenuItemView.Layout.height
                    height += spaceBetweenMenu
                    menuCount += 1
                    
                    if menuCount > moreButtonShowCount && !isShowAll {
                        break
                    }
                }
            }
            
            if menuCount > moreButtonShowCount && !isShowAll {
                height += moreButtonHeight
            }
            
            return height
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
    
    func bind(viewModel: StoreDetailCategorizedMenusCellViewModel) {
        menuStackView.bind(viewModel.output.data.menus, isShowAll: viewModel.output.isShowAll)
        
        let isShowMoreButton = viewModel.output.data.menus.map { $0.menus.count }.reduce(0, +) > Layout.moreButtonShowCount && viewModel.output.isShowAll
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
