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
    
    func bind(_ menus: [StoreDetailMenu], isShowAll: Bool) {
        var stackItemCount = 0
        let categories = menus.map { $0.category }
        
        for category in categories {
            let categoryItemView = StoreDetailMenuCategoryStackItemView()
            categoryItemView.bind(category)
            
            addArrangedSubview(categoryItemView)
            stackItemCount += 1
            
            let categoryMenus = menus.filter {
                $0.category.categoryId == category.categoryId && $0.isValid
            }
            
            categoryMenus.forEach {
                let categoryMenuItemView = StoreDetailMenuStackItemView()
                categoryMenuItemView.bind($0)
                
                addArrangedSubview(categoryMenuItemView)
                stackItemCount += 1
            }
            
            if (stackItemCount >= StoreDetailMenuCell.Layout.moreButtonShowCount) && !isShowAll {
                break
            }
        }
    }
    
    private func setup() {
        axis = .vertical
        spacing = 8
    }
}
