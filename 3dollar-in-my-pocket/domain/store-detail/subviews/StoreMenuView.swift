import UIKit
import RxSwift

final class StoreMenuView: BaseView {
  
  private let containerView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 12
  }
  
  private let titleLabel = UILabel().then {
    $0.font = .bold(size: 16)
    $0.textColor = R.color.black()
    $0.text = R.string.localization.store_detail_menu()
  }
  
  private let countLabel = UILabel().then {
    $0.font = .medium(size: 16)
    $0.textColor = R.color.black()
  }
  
  private let menuStackView = UIStackView().then {
    $0.axis = .vertical
    $0.distribution = .equalSpacing
    $0.backgroundColor = .clear
  }
  
  override func setup() {
    self.backgroundColor = .clear
    self.addSubViews([
      self.containerView,
      self.titleLabel,
      self.countLabel,
      self.menuStackView
    ])
  }
  
  override func bindConstraints() {
    self.containerView.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
      make.top.equalToSuperview().offset(12)
      make.bottom.equalTo(self.menuStackView).offset(16)
    }
    
    self.titleLabel.snp.makeConstraints { make in
      make.left.equalTo(self.containerView).offset(16)
      make.top.equalTo(self.containerView).offset(24)
    }
    
    self.countLabel.snp.makeConstraints { make in
      make.centerY.equalTo(self.titleLabel)
      make.left.equalTo(self.titleLabel.snp.right).offset(2)
    }
    
    self.menuStackView.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
      make.top.equalTo(self.titleLabel.snp.bottom).offset(14)
    }
    
    self.snp.makeConstraints { make in
      make.bottom.equalTo(self.containerView)
    }
  }
  
  func bind(store: Store) {
    self.countLabel.text = R.string.localization.store_detail_menu_format(store.menus.count)
    
    let subViews = self.subViewsFromMenus(
      categories: store.categories,
      menus: store.menus
    )
    
    for subView in subViews {
      self.menuStackView.addArrangedSubview(subView)
    }
  }
  
  private func subViewsFromMenus(categories: [StoreCategory], menus: [Menu]) -> [UIView] {
    var subViews: [UIView] = []
    
    let sortedCategories = categories.sorted { (category1, category2) -> Bool in
      menus.filter { $0.category == category1 }.count > menus.filter { $0.category == category2 }.count
    }
    
    for category in sortedCategories {
      let categoryView = StoreDetailMenuCategoryView()
      var menuSubViews: [UIView] = []
      
      for menu in menus {
        if menu.category == category && !menu.name.isEmpty {
          let menuView = StoreDetailMenuView()
          
          menuView.bind(menu: menu)
          menuSubViews.append(menuView)
        }
      }
      categoryView.bind(category: category, isEmpty: menuSubViews.isEmpty)
      subViews.append(categoryView)
      subViews += menuSubViews
    }
    
    return subViews
  }
}
