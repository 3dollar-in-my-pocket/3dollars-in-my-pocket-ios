import UIKit
import GoogleMobileAds
import NMapsMap

class CategoryListView: BaseView {
  
  let navigationBar = UIView().then {
    $0.backgroundColor = .white
  }
  
  let backBtn = UIButton().then {
    $0.setImage(UIImage.init(named: "ic_back_black"), for: .normal)
  }
  
  let categoryImage = UIImageView()
  
  let categoryBungeoppang = UIButton().then {
    $0.setTitle("붕어빵", for: .normal)
    $0.setTitleColor(UIColor.init(r: 34, g: 34, b: 34), for: .selected)
    $0.setTitleColor(UIColor.init(r: 196, g: 196, b: 196), for: .normal)
    $0.titleLabel?.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16 * RadioUtils.width)
  }
  
  let categoryTakoyaki = UIButton().then {
    $0.setTitle("문어빵", for: .normal)
    $0.setTitleColor(UIColor.init(r: 34, g: 34, b: 34), for: .selected)
    $0.setTitleColor(UIColor.init(r: 196, g: 196, b: 196), for: .normal)
    $0.titleLabel?.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16 * RadioUtils.width)
  }
  
  let categoryGyeranppang = UIButton().then {
    $0.setTitle("계란빵", for: .normal)
    $0.setTitleColor(UIColor.init(r: 34, g: 34, b: 34), for: .selected)
    $0.setTitleColor(UIColor.init(r: 196, g: 196, b: 196), for: .normal)
    $0.titleLabel?.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16 * RadioUtils.width)
  }
  
  let categoryHotteok = UIButton().then {
    $0.setTitle("호떡", for: .normal)
    $0.setTitleColor(UIColor.init(r: 34, g: 34, b: 34), for: .selected)
    $0.setTitleColor(UIColor.init(r: 196, g: 196, b: 196), for: .normal)
    $0.titleLabel?.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16 * RadioUtils.width)
  }
  
  let categoryStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 15
  }
  
  let mapView = NMFMapView()
  
  let myLocationBtn = UIButton().then {
    $0.setImage(UIImage.init(named: "ic_location"), for: .normal)
  }
  
  let pageView = UIView().then {
    $0.backgroundColor = UIColor.init(r: 245, g: 245, b: 245)
  }
  
  let adBannerView = GADBannerView()
  
  
  override func setup() {
    backgroundColor = .white
    setupNavigationBar()
    categoryStackView.addArrangedSubview(categoryBungeoppang)
    categoryStackView.addArrangedSubview(categoryTakoyaki)
    categoryStackView.addArrangedSubview(categoryGyeranppang)
    categoryStackView.addArrangedSubview(categoryHotteok)
    addSubViews(
      mapView, navigationBar,backBtn, categoryImage,
      categoryStackView, myLocationBtn, pageView, adBannerView
    )
  }
  
  override func bindConstraints() {
    navigationBar.snp.makeConstraints { (make) in
      make.left.right.equalToSuperview()
      make.top.equalTo(safeAreaLayoutGuide)
      make.height.equalTo(105)
    }
    
    backBtn.snp.makeConstraints { (make) in
      make.left.equalToSuperview().offset(24)
      make.top.equalTo(navigationBar).offset(8)
      make.width.height.equalTo(48)
    }
    
    myLocationBtn.snp.makeConstraints { (make) in
      make.right.equalTo(mapView.snp.right).offset(-24)
      make.bottom.equalTo(mapView.snp.bottom).offset(-15)
      make.width.height.equalTo(40)
    }
    
    categoryImage.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.centerY.equalTo(backBtn.snp.centerY)
      make.width.height.equalTo(60)
    }
    
    categoryStackView.snp.makeConstraints { (make) in
      make.top.equalTo(categoryImage.snp.bottom)
      make.centerX.equalToSuperview()
    }
    
    mapView.snp.makeConstraints { (make) in
      make.left.right.equalToSuperview()
      make.top.equalTo(navigationBar.snp.bottom).offset(-35)
      make.height.equalTo(264)
    }
    
    pageView.snp.makeConstraints { (make) in
      make.bottom.equalTo(adBannerView.snp.top)
      make.left.equalToSuperview()
      make.right.equalToSuperview()
      make.top.equalTo(mapView.snp.bottom)
    }
    
    adBannerView.snp.makeConstraints { make in
      make.left.right.bottom.equalToSuperview()
      make.height.equalTo(64)
    }
  }
  
  func setCategoryTitleImage(category: StoreCategory) {
    switch category {
    case .BUNGEOPPANG:
      categoryImage.image = UIImage.init(named: "img_category_fish")
    case .TAKOYAKI:
      categoryImage.image = UIImage.init(named: "img_category_takoyaki")
    case .GYERANPPANG:
      categoryImage.image = UIImage.init(named: "img_category_gyeranppang")
    case .HOTTEOK:
      categoryImage.image = UIImage.init(named: "img_category_hotteok")
    default:
      break
    }
  }
  
  private func setupNavigationBar() {
    navigationBar.layer.cornerRadius = 16
    navigationBar.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    
    navigationBar.layer.shadowOffset = CGSize(width: 8, height: 8)
    navigationBar.layer.shadowColor = UIColor.black.cgColor
    navigationBar.layer.shadowOpacity = 0.08
  }
}
