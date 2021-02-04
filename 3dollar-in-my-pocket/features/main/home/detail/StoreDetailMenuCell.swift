import UIKit
import RxSwift

class StoreDetailMenuCell: BaseTableViewCell {
  
  static let registerId = "\(StoreDetailMenuCell.self)"
  
  let menuStackView = UIStackView().then {
    $0.axis = .vertical
    $0.distribution = .equalSpacing
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 12
    $0.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    $0.isUserInteractionEnabled = true
  }
  
  override func setup() {
    self.selectionStyle = .none
    self.backgroundColor = .clear
    self.contentView.isUserInteractionEnabled = false
    self.addSubViews(menuStackView)
  }
  
  override func bindConstraints() {
    self.menuStackView.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
    }
  }
  
  func addMenu(menus: [Menu]) {
    if self.menuStackView.subviews.isEmpty {
      if menus.isEmpty {
        let emptyView = StoreDetailMenuEmptyView()
        
        self.menuStackView.addArrangedSubview(emptyView)
      } else {
        let subViews = self.subViewsFromMenus(menus: menus)
        
        for subView in subViews {
          self.menuStackView.addArrangedSubview(subView)
        }
        self.menuStackView.addArrangedSubview(StoreDetailMenuFooterView())
      }
    }
  }
  
  private func subViewsFromMenus(menus: [Menu]) -> [UIView] {
    var previousCategory = menus[0].category
    var subViews: [UIView] = []
    
    let firstCategoryView = StoreDetailMenuCategoryView()
    
    firstCategoryView.bind(category: menus[0].category ?? .BUNGEOPPANG)
    subViews.append(firstCategoryView)
    
    for menu in menus {
      if previousCategory != menu.category {
        let categoryView = StoreDetailMenuCategoryView()
        categoryView.bind(category: menu.category ?? .BUNGEOPPANG)
        subViews.append(categoryView)
        previousCategory = menu.category
      }
      let menuView = StoreDetailMenuView()
      menuView.bind(menu: menu)
      
      subViews.append(menuView)
    }
    
    return subViews
  }
}
