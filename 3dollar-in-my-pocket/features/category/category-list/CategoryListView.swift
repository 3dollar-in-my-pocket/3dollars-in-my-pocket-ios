import UIKit
import GoogleMobileAds
import NMapsMap

class CategoryListView: BaseView {
  
  let navigationView = UIView().then {
    $0.layer.cornerRadius = 20
    $0.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOpacity = 0.04
    $0.backgroundColor = .white
  }
  
  let backButton = UIButton().then {
    $0.setImage(UIImage.init(named: "ic_back_black"), for: .normal)
  }
  
  let titleStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 8
  }
  
  let categoryImage = UIImageView()
  
  let categoryLabel = UILabel().then {
    $0.text = "붕어빵"
    $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 16)
    $0.textColor = .black
  }
  
  let storeTableView = UITableView().then {
    $0.tableFooterView = UIView()
    $0.rowHeight = UITableView.automaticDimension
    $0.separatorStyle = .none
    $0.backgroundColor = UIColor(r: 250, g: 250, b: 250)
  }
  
//  let adBannerView = GADBannerView()
  
  
  override func setup() {
    self.backgroundColor = .white
    self.titleStackView.addArrangedSubview(categoryImage)
    self.titleStackView.addArrangedSubview(categoryLabel)
    self.addSubViews(storeTableView, navigationView, backButton, titleStackView)
  }
  
  override func bindConstraints() {
    self.navigationView.snp.makeConstraints { make in
      make.left.right.top.equalToSuperview()
      make.bottom.equalTo(self.safeAreaLayoutGuide.snp.top).offset(60)
    }
    
    self.backButton.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.bottom.equalTo(self.navigationView).offset(-21)
    }
    
    self.titleStackView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalTo(self.backButton)
    }
    
    self.categoryImage.snp.makeConstraints { make in
      make.width.height.equalTo(32)
    }
    
    self.storeTableView.snp.makeConstraints { make in
      make.top.equalTo(self.navigationView.snp.bottom).offset(-20)
      make.left.right.equalToSuperview()
      make.bottom.equalTo(safeAreaLayoutGuide)
    }
  }
  
  func setCategoryTitle(category: StoreCategory) {
    self.categoryImage.image = category.image
    self.categoryLabel.text = category.name
  }
}
