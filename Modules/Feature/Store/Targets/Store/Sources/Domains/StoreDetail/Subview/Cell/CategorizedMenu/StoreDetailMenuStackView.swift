import UIKit

import Common
import DesignSystem
import Model

final class StoreDetailMenuStackView: UIStackView {
    typealias CategorizedMenu = StoreCategorizedMenusSectionResponse.StoreCategorizedMenuSectionResponse
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepareForReuse() {
        arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    func bind(_ menus: [CategorizedMenu], isShowAll: Bool) {
        var menuCount = 0
        
        for categorizedMenu in menus {
            let categoryItemView = StoreDetailMenuCategoryItemView()
            categoryItemView.bind(categorizedMenu.category)
            
            addArrangedSubview(categoryItemView)
            
            for menu in categorizedMenu.menus {
                let categoryMenuItemView = StoreDetailMenuItemView()
                categoryMenuItemView.bind(menu)
                
                addArrangedSubview(categoryMenuItemView)
                menuCount += 1
                
                if (menuCount >= StoreDetailCategorizedMenusCell.Layout.moreButtonShowCount) && !isShowAll {
                    break
                }
            }
        }
    }
    
    private func setup() {
        axis = .vertical
        spacing = 8
    }
}
