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
    $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 16)
    $0.textColor = .black
  }
  
  let mapView = NMFMapView()
  
  let currentLocationButton = UIButton().then {
    $0.setImage(UIImage.init(named: "ic_current_location"), for: .normal)
  }
  
  let categoryTitleLabel = UILabel().then {
    $0.font = UIFont(name: "AppleSDGothicNeo-Light", size: 24)
    $0.textColor = .black
    $0.numberOfLines = 0
  }
  
  let distanceOrderButton = UIButton().then {
    $0.setTitle("category_ordering_distance".localized, for: .normal)
    $0.setTitleColor(.black, for: .selected)
    $0.setTitleColor(UIColor.init(r: 189, g: 189, b: 189), for: .normal)
    $0.isSelected = true
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 14)
  }
  
  let reviewOrderButton = UIButton().then {
    $0.setTitle("category_ordering_review".localized, for: .normal)
    $0.setTitleColor(.black, for: .selected)
    $0.setTitleColor(UIColor.init(r: 189, g: 189, b: 189), for: .normal)
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 14)
  }
  
  let storeTableView = UITableView(frame: .zero, style: .grouped).then {
    $0.tableFooterView = UIView()
    $0.rowHeight = UITableView.automaticDimension
    $0.separatorStyle = .none
    $0.sectionHeaderHeight = UITableView.automaticDimension
    $0.estimatedSectionHeaderHeight = 1
    $0.backgroundColor = UIColor(r: 250, g: 250, b: 250)
    $0.showsVerticalScrollIndicator = false
    $0.contentInsetAdjustmentBehavior = .never
  }
  
  let emptyImage = UIImageView().then {
    $0.image = UIImage(named: "img_empty")
    $0.isHidden = true
  }
  
  let emptyLabel = UILabel().then {
    $0.text = "category_list_empty".localized
    $0.textColor = UIColor(r: 200, g: 200, b: 200)
    $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 16)
    $0.isHidden = true
  }
  
  
  override func setup() {
    self.backgroundColor = UIColor(r: 250, g: 250, b: 250)
    self.titleStackView.addArrangedSubview(categoryImage)
    self.titleStackView.addArrangedSubview(categoryLabel)
    self.addSubViews(
      storeTableView, mapView, navigationView, backButton,
      currentLocationButton, reviewOrderButton, distanceOrderButton,
      categoryTitleLabel, titleStackView, emptyImage, emptyLabel
    )
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
    
    self.mapView.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.top.equalTo(self.navigationView.snp.bottom).offset(-20)
      make.height.equalTo(339 * RatioUtils.heightRatio)
    }
    
    self.currentLocationButton.snp.makeConstraints { (make) in
      make.right.equalTo(mapView.snp.right).offset(-24)
      make.bottom.equalTo(mapView.snp.bottom).offset(-15)
      make.width.height.equalTo(48)
    }
    
    self.categoryTitleLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-129)
      make.top.equalTo(self.mapView.snp.bottom).offset(40)
    }
    
    self.reviewOrderButton.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-24)
      make.bottom.equalTo(self.categoryTitleLabel)
    }
    
    self.distanceOrderButton.snp.makeConstraints { make in
      make.bottom.equalTo(self.reviewOrderButton)
      make.right.equalToSuperview().offset(-75)
    }
    
    self.storeTableView.snp.makeConstraints { make in
      make.top.equalTo(self.categoryTitleLabel.snp.bottom)
      make.left.right.equalToSuperview()
      make.bottom.equalTo(safeAreaLayoutGuide)
    }
    
    self.emptyImage.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.categoryTitleLabel.snp.bottom).offset(32)
    }
    
    self.emptyLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.emptyImage.snp.bottom).offset(8)
    }
  }
  
  func bind(category: StoreCategory) {
    self.categoryImage.image = category.image
    self.categoryLabel.text = category.name
    
    let text = "category_list_\(category.lowcase)".localized
    let attributedString = NSMutableAttributedString(string: text)
    let boldTextRange = (text as NSString).range(of: "shared_category_\(category.lowcase)".localized)
    
    attributedString.addAttribute(
      .font,
      value: UIFont(name: "AppleSDGothicNeoEB00", size: 24)!,
      range: boldTextRange
    )
    attributedString.addAttribute(
      .kern,
      value: -1.2,
      range: .init(location: 0, length: text.count)
    )
    self.categoryTitleLabel.attributedText = attributedString
  }
  
  func onTapOrderButton(order: CategoryOrder) {
    self.distanceOrderButton.isSelected = order == .distance
    self.reviewOrderButton.isSelected = order == .review
  }
}
