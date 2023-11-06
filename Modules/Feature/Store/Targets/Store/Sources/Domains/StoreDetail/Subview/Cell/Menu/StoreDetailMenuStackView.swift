import UIKit

import Common
import DesignSystem
import Model

final class StoreDetailMenuStackView: UIStackView {
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
    
    func bind(_ menus: [StoreDetailMenu], isShowAll: Bool) {
        let categories = menus.map { $0.category }.unique
        var menuCount = 0
        
        for category in categories {
            let categoryItemView = StoreDetailMenuCategoryStackItemView()
            categoryItemView.bind(category)
            
            addArrangedSubview(categoryItemView)
            
            let categoryMenus = menus.filter { $0.category == category && $0.isValid }
            
            for categoryMenu in categoryMenus {
                let categoryMenuItemView = StoreDetailMenuStackItemView()
                categoryMenuItemView.bind(categoryMenu)
                
                addArrangedSubview(categoryMenuItemView)
                menuCount += 1
                
                if (menuCount >= StoreDetailMenuCell.Layout.moreButtonShowCount) && !isShowAll {
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
