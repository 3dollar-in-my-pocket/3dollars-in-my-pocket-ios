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
    $0.layer.cornerRadius = 24
  }
  
  let bottomContainerView = UIView().then {
    $0.layer.cornerRadius = 24
    $0.backgroundColor = R.color.gray95()
  }
  
  let bottomLeftCircleView = UIView().then {
    $0.layer.cornerRadius = 28
    $0.backgroundColor = R.color.gray90()
  }
  
  let bottomRightCircleView = UIView().then {
    $0.layer.cornerRadius = 28
    $0.backgroundColor = R.color.gray90()
  }
  
  let bottomRightCategoryImage = UIImageView()
  
  let indicatorImage = UIImageView().then {
    $0.image = R.image.img_distance_indicator()
  }
  
  let distanceLabel = UILabel().then {
    $0.font = .regular(size: 14)
    $0.textColor = R.color.pink()
  }
  
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
      self.bottomContainerView,
      self.bottomLeftCircleView,
      self.bottomRightCircleView,
      self.bottomRightCategoryImage,
      self.indicatorImage,
      self.distanceLabel
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
      make.bottom.equalTo(self.safeAreaLayoutGuide).offset(-10)
      make.top.equalTo(self.bottomLeftCircleView).offset(-16)
    }
    
    self.bottomLeftCircleView.snp.makeConstraints { make in
      make.left.equalTo(self.bottomContainerView).offset(10)
      make.bottom.equalTo(self.bottomContainerView).offset(-16)
      make.width.height.equalTo(56)
    }
    
    self.bottomRightCircleView.snp.makeConstraints { make in
      make.centerY.equalTo(self.bottomLeftCircleView)
      make.right.equalTo(self.bottomContainerView).offset(-10)
      make.width.height.equalTo(56)
    }
    
    self.bottomRightCategoryImage.snp.makeConstraints { make in
      make.center.equalTo(self.bottomRightCircleView)
      make.width.height.equalTo(40)
    }
    
    self.distanceLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalTo(self.bottomContainerView).offset(-16)
    }
    
    self.indicatorImage.snp.makeConstraints { make in
      make.centerX.equalTo(distanceLabel)
      make.bottom.equalTo(self.distanceLabel.snp.top).offset(-16)
    }
    
    self.mapContainerView.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
      make.bottom.equalTo(self.bottomContainerView.snp.top).offset(-20)
      make.top.equalTo(self.titleLabel.snp.bottom).offset(22)
    }
    
    self.storeCategoryImage.snp.makeConstraints { make in
      make.left.equalTo(self.mapContainerView).offset(19)
      make.top.equalTo(self.mapContainerView).offset(10)
      make.width.height.equalTo(44)
    }
    
    self.storeNameLabel.snp.makeConstraints { make in
      make.left.equalTo(self.storeCategoryImage.snp.right).offset(19)
      make.top.equalTo(self.mapContainerView).offset(13)
      make.right.equalTo(self.mapContainerView).offset(-19)
    }
    
    self.storeCategoryLabel.snp.makeConstraints { make in
      make.left.right.equalTo(self.storeNameLabel)
      make.top.equalTo(self.storeNameLabel.snp.bottom).offset(7)
    }
    
    self.mapView.snp.makeConstraints { make in
      make.left.right.bottom.equalTo(self.mapContainerView)
      make.top.equalTo(self.storeCategoryImage.snp.bottom).offset(14)
    }
  }
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    self.drawDash()
  }
  
  private func drawDash() {
    let bzPath = UIBezierPath()
    bzPath.lineWidth = 3
    bzPath.lineCapStyle = .round

    let startingPoint = CGPoint(
      x: self.bottomLeftCircleView.frame.maxX + 8,
      y: self.bottomLeftCircleView.frame.midY
    )
    let endingPoint = CGPoint(
      x: self.bottomRightCircleView.frame.minX - 8,
      y: self.bottomRightCircleView.frame.midY
    )

    bzPath.move(to: startingPoint)
    bzPath.addLine(to: endingPoint)
    bzPath.close()
    bzPath.setLineDash([3, 10], count: 2, phase: 0)
    R.color.red()?.set()
    bzPath.stroke()
  }
  
  fileprivate func bind(store: Store) {
    self.storeNameLabel.text = store.storeName
    self.storeCategoryImage.image = store.categories[0].image
    self.setCategories(categories: store.categories)
    self.bottomRightCategoryImage.image = store.categories[0].image
  }
  
  private func setCategories(categories: [StoreCategory]) {
    var categoryString = ""
    for category in categories {
      categoryString.append("#\(category.name) ")
    }
    self.storeCategoryLabel.text = categoryString
  }
}

extension Reactive where Base: VisitView {
  
  var store: Binder<Store> {
    return Binder(self.base) { view, store in
      view.bind(store: store)
    }
  }
}
