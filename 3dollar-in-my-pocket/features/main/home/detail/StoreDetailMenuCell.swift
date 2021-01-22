import UIKit

class StoreDetailMenuCell: BaseTableViewCell {
  
  static let registerId = "\(StoreDetailMenuCell.self)"
  
  let menuStackView = UIStackView().then {
    $0.axis = .vertical
    $0.distribution = .equalSpacing
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 12
    $0.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    self.menuStackView.subviews.forEach { $0.removeFromSuperview() }
  }
  
  override func setup() {
    selectionStyle = .none
    backgroundColor = .clear
    addSubViews(menuStackView)
  }
  
  override func bindConstraints() {
    self.menuStackView.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
    }
  }
  
  func addMenu() {
    let categoryView1 = StoreDetailMenuCategoryView()
    let categoryView2 = StoreDetailMenuCategoryView()
    let menuView1 = StoreDetailMenuView()
    let menuView2 = StoreDetailMenuView()
    let menuView3 = StoreDetailMenuView()
    let menuView4 = StoreDetailMenuView()
    let footerView = StoreDetailMenuFooterView()
    
    self.menuStackView.addArrangedSubview(categoryView1)
    self.menuStackView.addArrangedSubview(menuView1)
    self.menuStackView.addArrangedSubview(menuView2)
    self.menuStackView.addArrangedSubview(categoryView2)
    self.menuStackView.addArrangedSubview(menuView3)
    self.menuStackView.addArrangedSubview(menuView4)
    self.menuStackView.addArrangedSubview(footerView)
    
    // TODO: 6줄 이상이면 모두보기 버튼, 없으면 그냥 빈 뷰
  }
}
