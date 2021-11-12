import UIKit

import RxSwift
import RxCocoa
import NMapsMap

final class VisitView: BaseView {
  
  let closeButton = UIButton().then {
    $0.setImage(R.image.ic_close_white(), for: .normal)
  }
  
  let bedgeImage = UIImageView().then {
    $0.image = R.image.img_bedge()
  }
  
  let titleLabel = UILabel().then {
    $0.textColor = R.color.gray0()
    $0.font = UIFont.regular(size: 28)
    $0.textAlignment = .center
    let text = R.string.localization.visit_title_disable()
    let attributedString = NSMutableAttributedString(string: text)
    let boldTextRange = (text as NSString).range(of: "방문을 인증")
    
    attributedString.addAttribute(
      .font,
      value: UIFont(name: "AppleSDGothicNeoEB00", size: 28) as Any,
      range: boldTextRange
    )
    $0.attributedText = attributedString
    $0.numberOfLines = 0
  }
  
  let mapContainerView = UIView().then {
    $0.layer.cornerRadius = 20
    $0.backgroundColor = R.color.gray95()
  }
  
  let storeCategoryImage = UIImageView()
  
  let storeNameLabel = UILabel().then {
    $0.font = R.font.appleSDGothicNeoEB00(size: 16)
    $0.textColor = R.color.gray0()
  }
  
  let storeCategoryLabel = UILabel().then {
    $0.font = .regular(size: 12)
    $0.textColor = R.color.pink()
  }
  
  let mapView = NMFMapView().then {
    $0.layer.cornerRadius = 20
    $0.positionMode = .direction
  }
  
  let currentLocationButton = UIButton().then {
    $0.setImage(R.image.ic_current_location(), for: .normal)
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    $0.layer.shadowOpacity = 0.15
  }
  
  let bottomContainerView = UIView().then {
    $0.layer.cornerRadius = 24
    $0.backgroundColor = R.color.gray95()
  }
  
  let bottomLeftCircleView = UIView().then {
    $0.layer.cornerRadius = 28 * RatioUtils.heightRatio
    $0.backgroundColor = R.color.gray90()
  }
  
  let bottomRightCircleView = UIView().then {
    $0.layer.cornerRadius = 28 * RatioUtils.heightRatio
    $0.backgroundColor = R.color.gray90()
  }
  
  let bottomRightCategoryImage = UIImageView()
  
  let indicatorImage = UIImageView().then {
    $0.image = R.image.img_distance_indicator()
  }
  
  let dashedLine = UIImageView().then {
    $0.image = R.image.img_line_dashed()
  }
  
  let distanceLabel = UILabel().then {
    $0.font = .regular(size: 14)
    $0.textColor = R.color.pink()
  }
  
  let bottomSheetContainerView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 21
    $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
  }
  
  let notExistedButton = VisitButton(type: .notExisted)
  
  let existedButton = VisitButton(type: .existed)
  
  override func setup() {
    self.backgroundColor = .black
    
    self.addSubViews([
      self.closeButton,
      self.bedgeImage,
      self.titleLabel,
      self.mapContainerView,
      self.storeCategoryImage,
      self.storeNameLabel,
      self.storeCategoryLabel,
      self.mapView,
      self.currentLocationButton,
      self.bottomContainerView,
      self.bottomLeftCircleView,
      self.bottomRightCircleView,
      self.bottomRightCategoryImage,
      self.indicatorImage,
      self.dashedLine,
      self.distanceLabel,
      self.bottomSheetContainerView,
      self.notExistedButton,
      self.existedButton
    ])
  }
  
  override func bindConstraints() {
    self.closeButton.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalTo(self.safeAreaLayoutGuide).offset(14)
    }
    
    self.bedgeImage.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.safeAreaLayoutGuide).offset(2)
      make.width.height.equalTo(48)
    }
    
    self.titleLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.bedgeImage.snp.bottom).offset(24)
    }
    
    self.bottomContainerView.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
      make.bottom.equalTo(self.safeAreaLayoutGuide).offset(-10 * RatioUtils.heightRatio)
      make.top.equalTo(self.bottomLeftCircleView).offset(-16 * RatioUtils.heightRatio)
    }
    
    self.bottomLeftCircleView.snp.makeConstraints { make in
      make.left.equalTo(self.bottomContainerView).offset(10)
      make.bottom.equalTo(self.bottomContainerView).offset(-16 * RatioUtils.heightRatio)
      make.width.height.equalTo(56 * RatioUtils.heightRatio)
    }
    
    self.bottomRightCircleView.snp.makeConstraints { make in
      make.centerY.equalTo(self.bottomLeftCircleView)
      make.right.equalTo(self.bottomContainerView).offset(-10)
      make.width.height.equalTo(56 * RatioUtils.heightRatio)
    }
    
    self.bottomRightCategoryImage.snp.makeConstraints { make in
      make.center.equalTo(self.bottomRightCircleView)
      make.width.height.equalTo(40 * RatioUtils.heightRatio)
    }
    
    self.distanceLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.dashedLine).offset(11 * RatioUtils.heightRatio)
    }
    
    self.dashedLine.snp.makeConstraints { make in
      make.centerY.equalTo(self.bottomContainerView)
      make.left.equalTo(self.bottomLeftCircleView.snp.right)
      make.right.equalTo(self.bottomRightCircleView.snp.left)
    }
    
    self.indicatorImage.snp.makeConstraints { make in
      make.centerX.equalTo(distanceLabel)
      make.bottom.equalTo(self.dashedLine.snp.top).offset(-5 * RatioUtils.heightRatio)
      make.width.equalTo(24 * RatioUtils.heightRatio)
      make.height.equalTo(29 * RatioUtils.heightRatio)
    }
    
    self.mapContainerView.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
      make.bottom.equalTo(self.mapView)
      make.top.equalTo(self.titleLabel.snp.bottom).offset(22)
    }
    
    self.storeCategoryImage.snp.makeConstraints { make in
      make.left.equalTo(self.mapContainerView).offset(19)
      make.top.equalTo(self.mapContainerView).offset(10 * RatioUtils.heightRatio)
      make.width.height.equalTo(44)
    }
    
    self.storeNameLabel.snp.makeConstraints { make in
      make.left.equalTo(self.storeCategoryImage.snp.right).offset(19)
      make.top.equalTo(self.mapContainerView).offset(13 * RatioUtils.heightRatio)
      make.right.equalTo(self.mapContainerView).offset(-19)
    }
    
    self.storeCategoryLabel.snp.makeConstraints { make in
      make.left.right.equalTo(self.storeNameLabel)
      make.top.equalTo(self.storeNameLabel.snp.bottom).offset(7 * RatioUtils.heightRatio)
    }
    
    self.mapView.snp.makeConstraints { make in
      make.left.right.equalTo(self.mapContainerView)
      make.top.equalTo(self.storeCategoryImage.snp.bottom).offset(14 * RatioUtils.heightRatio)
      make.height.equalTo(380 * RatioUtils.heightRatio)
    }
    
    self.currentLocationButton.snp.makeConstraints { make in
      make.right.equalTo(self.mapView).offset(-16)
      make.bottom.equalTo(self.mapView).offset(-16)
    }
    
    self.bottomSheetContainerView.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.top.equalTo(self.snp.bottom)
      make.height.equalTo(
        246 * RatioUtils.heightRatio
          + (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0)
      )
    }
    
    self.notExistedButton.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalTo(self.bottomSheetContainerView).offset(30 * RatioUtils.heightRatio)
      make.size.equalTo(VisitButton.size)
    }
    
    self.existedButton.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-24)
      make.centerY.equalTo(self.notExistedButton)
      make.size.equalTo(VisitButton.size)
    }
  }
  
  func bindDistance(distance: Int) {
    self.distanceLabel.text = "인증까지 \(distance)m"
  }
  
  func moveCamera(latitude: Double, longitude: Double) {
    let cameraUpdate = NMFCameraUpdate(scrollTo: .init(lat: latitude, lng: longitude))
    
    cameraUpdate.animation = .easeIn
    self.mapView.moveCamera(cameraUpdate)
  }
  
  func bindVisitable(isVisitable: Bool) {
    if isVisitable {
      self.mapView.snp.updateConstraints { make in
        make.height.equalTo(200)
      }
      self.bottomSheetContainerView.snp.remakeConstraints { make in
        make.left.right.equalToSuperview()
        make.bottom.equalToSuperview()
        make.height.equalTo(
          246 * RatioUtils.heightRatio
            + (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0)
        )
      }
      UIView.animate(withDuration: 0.3) { [weak self] in
        guard let self = self else { return }
        self.backgroundColor = R.color.pink()
        self.mapContainerView.backgroundColor = UIColor(r: 243, g: 132, b: 141)
        self.layoutIfNeeded()
      }
      self.storeCategoryLabel.textColor = .white
    } else {
      self.mapView.snp.updateConstraints { make in
        make.height.equalTo(380 * RatioUtils.heightRatio)
      }
      self.bottomSheetContainerView.snp.remakeConstraints { make in
        make.left.right.equalToSuperview()
        make.top.equalTo(self.snp.bottom)
        make.height.equalTo(
          246 * RatioUtils.heightRatio
            + (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0)
        )
      }
      UIView.animate(withDuration: 0.3) { [weak self] in
        guard let self = self else { return }
        self.backgroundColor = .black
        self.mapContainerView.backgroundColor = R.color.gray95()
        self.layoutIfNeeded()
      }
      self.storeCategoryLabel.textColor = R.color.pink()
      self.titleLabel.textColor = .white
    }
    self.setupTitleLabel(isVisitable: isVisitable)
    self.currentLocationButton.isHidden = isVisitable
  }
  
  fileprivate func bind(store: Store) {
    self.storeNameLabel.text = store.storeName
    self.storeCategoryImage.image = store.categories[0].image
    self.setCategories(categories: store.categories)
    self.bottomRightCategoryImage.image = store.categories[0].image
    self.setupMap(latitude: store.latitude, longitude: store.longitude)
  }
  
  private func setCategories(categories: [StoreCategory]) {
    var categoryString = ""
    for category in categories {
      categoryString.append("#\(category.name) ")
    }
    self.storeCategoryLabel.text = categoryString
  }
  
  private func setupMap(latitude: Double, longitude: Double) {
    self.moveCamera(latitude: latitude, longitude: longitude)
    self.setupRangeOverlayView(latitude: latitude, longitude: longitude)
    self.setupMarker(latitude: latitude, longitude: longitude)
  }
  
  private func setupRangeOverlayView(latitude: Double, longitude: Double) {
    let rangeOverlayView = NMFCircleOverlay().then {
      $0.center = NMGLatLng(lat: latitude, lng: longitude)
      $0.radius = 500
      $0.fillColor = R.color.pink()?.withAlphaComponent(0.2) ?? .clear
    }
    
    rangeOverlayView.mapView = self.mapView
  }
  
  private func setupMarker(latitude: Double, longitude: Double) {
    let marker = NMFMarker().then {
      $0.position = NMGLatLng(lat: latitude, lng: longitude)
      $0.iconImage = NMFOverlayImage(name: "ic_marker")
      $0.width = 30
      $0.height = 40
    }
    
    marker.mapView = self.mapView
    marker.globalZIndex = 1
  }
  
  private func setupTitleLabel(isVisitable: Bool) {
    let text = isVisitable
      ? R.string.localization.visit_title_enable()
      : R.string.localization.visit_title_disable()
    let attributedString = NSMutableAttributedString(string: text)
    let boldTextRange = (text as NSString).range(of: "방문을 인증")
    
    attributedString.addAttribute(
      .font,
      value: UIFont(name: "AppleSDGothicNeoEB00", size: 28) as Any,
      range: boldTextRange
    )
    self.titleLabel.attributedText = attributedString
    self.titleLabel.textColor = isVisitable
      ? .black
      : .white
  }
}

extension Reactive where Base: VisitView {
  
  var store: Binder<Store> {
    return Binder(self.base) { view, store in
      view.bind(store: store)
    }
  }
}
