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
  
  let storeOverview = StoreOverview()
  
  fileprivate let storeInfoView = StoreInfoView()
  
  fileprivate let storeMenuView = StoreMenuView()
  
  let storePhotoCollectionView = StorePhotoCollectionView()
  
  let storeReviewTableView = StoreReviewTableView()
  
  private let registerButtonBg = UIView().then {
    $0.layer.cornerRadius = 37
    
    let shadowLayer = CAShapeLayer()
    
    shadowLayer.path = UIBezierPath(
      roundedRect: CGRect(x: 0, y: 0, width: 232, height: 64),
      cornerRadius: 37
    ).cgPath
    shadowLayer.fillColor = UIColor.init(r: 255, g: 255, b: 255, a: 0.6).cgColor
    shadowLayer.shadowColor = UIColor.black.cgColor
    shadowLayer.shadowPath = nil
    shadowLayer.shadowOffset = CGSize(width: 0, height: 1)
    shadowLayer.shadowOpacity = 0.3
    shadowLayer.shadowRadius = 10
    $0.layer.insertSublayer(shadowLayer, at: 0)
  }
  
  let registerButton = UIButton().then {
    $0.setTitle("store_detail_add_visit_history".localized, for: .normal)
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 16)
    $0.setBackgroundColor(UIColor(r: 255, g: 92, b: 67), for: .normal)
    $0.layer.cornerRadius = 24
    $0.layer.masksToBounds = true
  }
  
  override func setup() {
    self.scrollView.delegate = self
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
      self.deleteRequestButton,
      self.registerButtonBg,
      self.registerButton
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
      make.height.equalTo(0)
    }
    
    self.registerButtonBg.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.width.equalTo(232)
      make.height.equalTo(64)
      make.bottom.equalToSuperview().offset(-32)
    }
    
    self.registerButton.snp.makeConstraints { (make) in
      make.left.equalTo(registerButtonBg.snp.left).offset(8)
      make.right.equalTo(registerButtonBg.snp.right).offset(-8)
      make.top.equalTo(registerButtonBg.snp.top).offset(8)
      make.bottom.equalTo(registerButtonBg.snp.bottom).offset(-8)
    }
  }
  
  fileprivate func bind(category: StoreCategory) {
    self.mainCategoryImage.image = UIImage(named: "img_60_\(category.lowcase)")
  }
  
  func updateReviewTableViewHeight(reviews: [Review?]) {
    self.storeReviewTableView.snp.updateConstraints { make in
      make.height.equalTo(143 * reviews.count + 64)
    }
  }
  
  func hideRegisterButton() {
    if registerButtonBg.alpha != 0 {
      let originalBgTransform = self.registerButtonBg.transform
      let originalBtnTransform = self.registerButton.transform
      
      UIView.animateKeyframes(withDuration: 0.2, delay: 0, animations: { [weak self] in
        self?.registerButtonBg.transform = originalBgTransform.translatedBy(x: 0.0, y: 90)
        self?.registerButtonBg.alpha = 0
        
        self?.registerButton.transform = originalBtnTransform.translatedBy(x: 0.0, y: 90)
        self?.registerButton.alpha = 0
      })
    }
  }
  
  func showRegisterButton() {
    if registerButtonBg.alpha != 1 {
      let originalBgTransform = self.registerButtonBg.transform
      let originalBtnTransform = self.registerButton.transform
      
      UIView.animateKeyframes(withDuration: 0.2, delay: 0, animations: { [weak self] in
        self?.registerButtonBg.transform = originalBgTransform.translatedBy(x: 0.0, y: -90)
        self?.registerButtonBg.alpha = 1
        
        self?.registerButton.transform = originalBtnTransform.translatedBy(x: 0.0, y: -90)
        self?.registerButton.alpha = 1
      })
    }
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
      view.storeReviewTableView.bind(store: store, userId: UserDefaultsUtil().getUserId())
    }
  }
  
  var tapShareButton: ControlEvent<Void> {
    return base.storeOverview.shareButton.rx.tap
  }
  
  var tapTransferButton: ControlEvent<Void> {
    return base.storeOverview.transferButton.rx.tap
  }
  
  var tapEditStore: ControlEvent<Void> {
    return base.storeInfoView.editButton.rx.tap
  }
  
  var tapWriteReviewButton: ControlEvent<Void> {
    return base.storeReviewTableView.addPhotoButton.rx.tap
  }
  
  var tapAddPhotoButton: ControlEvent<Void> {
    return base.storePhotoCollectionView.addPhotoButton.rx.tap
  }
}

extension StoreDetailView: UIScrollViewDelegate {
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    self.hideRegisterButton()
  }
  
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
      self.showRegisterButton()
    }
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    self.showRegisterButton()
  }
}

