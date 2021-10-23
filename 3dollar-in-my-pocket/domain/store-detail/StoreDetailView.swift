import UIKit
import RxSwift
import RxCocoa

final class StoreDetailView: BaseView {
  
  private let navigationView = UIView().then {
    $0.layer.cornerRadius = 20
    $0.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOpacity = 0.04
    $0.backgroundColor = .white
  }
  
  let backButton = UIButton().then {
    $0.setImage(R.image.ic_back_black(), for: .normal)
  }
  
  let mainCategoryImage = UIImageView()
  
  let deleteRequestButton = UIButton().then {
    $0.setTitle(R.string.localization.store_detail_delete_request(), for: .normal)
    $0.setTitleColor(R.color.red(), for: .normal)
    $0.titleLabel?.font = .semiBold(size: 14)
  }
  
  private let scrollView = UIScrollView()
  
  private let containerView = UIView()
  
  fileprivate let storeOverview = StoreOverview()
  
  fileprivate let storeInfoView = StoreInfoView()
  
  fileprivate let storeMenuView = StoreMenuView()
  
  fileprivate let storePhotoCollectionView = StorePhotoCollectionView()
  
  fileprivate let storeReviewTableView = StoreReviewTableView()
  
  
  override func setup() {
    self.containerView.addSubViews([
      self.storeOverview,
      self.storeInfoView,
      self.storeMenuView,
      self.storePhotoCollectionView,
      self.storeReviewTableView
    ])
    
    self.scrollView.addSubview(self.containerView)
    
    self.addSubViews([
      self.scrollView,
      self.navigationView,
      self.backButton,
      self.mainCategoryImage,
      self.deleteRequestButton
    ])
    self.backgroundColor = UIColor(r: 250, g: 250, b: 250)
  }
  
  override func bindConstraints() {
    self.navigationView.snp.makeConstraints { (make) in
      make.left.right.top.equalToSuperview()
      make.bottom.equalTo(self.safeAreaLayoutGuide.snp.top).offset(60)
    }
    
    self.backButton.snp.makeConstraints { (make) in
      make.left.equalToSuperview().offset(24)
      make.centerY.equalTo(self.mainCategoryImage)
    }
    
    self.mainCategoryImage.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.width.height.equalTo(60)
      make.bottom.equalTo(self.navigationView).offset(-3)
    }
    
    self.deleteRequestButton.snp.makeConstraints { make in
      make.centerY.equalTo(self.mainCategoryImage)
      make.right.equalToSuperview().offset(-24)
    }
    
    self.scrollView.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.bottom.equalTo(safeAreaLayoutGuide)
      make.top.equalTo(self.navigationView.snp.bottom).offset(-20)
    }
    
    self.containerView.snp.makeConstraints { make in
      make.edges.equalTo(self.scrollView)
      make.width.equalTo(UIScreen.main.bounds.width)
      make.top.equalTo(self.storeOverview)
      make.bottom.equalTo(self.storeReviewTableView).offset(40)
    }
    
    self.storeOverview.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.left.equalToSuperview()
      make.right.equalToSuperview()
    }
    
    self.storeInfoView.snp.makeConstraints { make in
      make.left.equalToSuperview()
      make.right.equalToSuperview()
      make.top.equalTo(self.storeOverview.snp.bottom)
    }
    
    self.storeMenuView.snp.makeConstraints { make in
      make.left.equalToSuperview()
      make.right.equalToSuperview()
      make.top.equalTo(self.storeInfoView.snp.bottom)
    }
    
    self.storePhotoCollectionView.snp.makeConstraints { make in
      make.left.equalToSuperview()
      make.right.equalToSuperview()
      make.top.equalTo(self.storeMenuView.snp.bottom)
    }
    
    self.storeReviewTableView.snp.makeConstraints { make in
      make.left.equalToSuperview()
      make.right.equalToSuperview()
      make.top.equalTo(self.storePhotoCollectionView.snp.bottom)
    }
  }
  
  func bind(category: StoreCategory) {
    self.mainCategoryImage.image = UIImage(named: "img_60_\(category.lowcase)")
  }
}

extension Reactive where Base: StoreDetailView {
  var store: Binder<Store> {
    return Binder(self.base) { view, store in
      view.bind(category: store.categories[0])
      view.storeOverview.bind(store: store)
      view.storeInfoView.bind(store: store)
      view.storeMenuView.bind(store: store)
      view.storePhotoCollectionView.bind(store: store)
      view.storeReviewTableView.bind(store: store)
    }
  }
}
