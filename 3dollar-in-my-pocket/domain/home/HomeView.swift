import UIKit
import NMapsMap

class HomeView: BaseView {
  
  let mapView = NMFMapView().then {
    $0.positionMode = .direction
    $0.zoomLevel = 15
  }
  
  let addressContainerView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 16
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    $0.layer.shadowOpacity = 0.08
  }
  
  let addressButton = UIButton().then {
    $0.titleLabel?.font = .semiBold(size: 16)
    $0.setImage(R.image.ic_arrow_bottom_black(), for: .normal)
    $0.semanticContentAttribute = .forceRightToLeft
    $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -8)
    $0.setTitleColor(.black, for: .normal)
  }
  
  let researchButton = UIButton().then {
    $0.setTitle(R.string.localization.home_research(), for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.titleLabel?.font = .semiBold(size: 14)
    $0.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
    $0.backgroundColor = R.color.red()
    $0.layer.cornerRadius = 20
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    $0.layer.shadowOpacity = 0.08
    $0.alpha = 0.0
  }
  
  let storeCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout()
  ).then {
    let layout = HomeStoreFlowLayout()
    
    layout.scrollDirection = .horizontal
    layout.minimumInteritemSpacing = 17
    layout.itemSize = StoreCell.itemSize
    $0.collectionViewLayout = layout
    $0.backgroundColor = .clear
    $0.showsHorizontalScrollIndicator = false
    $0.contentInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    $0.register([StoreCell.self])
  }
  
  let emptyCell = HomeEmptyStoreCell().then {
    $0.isHidden = true
  }
  
  let currentLocationButton = UIButton().then {
    $0.setImage(R.image.ic_current_location(), for: .normal)
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    $0.layer.shadowOpacity = 0.15
  }
  
  let tossButton = UIButton().then {
    $0.setImage(R.image.ic_toss(), for: .normal)
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    $0.layer.shadowOpacity = 0.15
  }
  
  
  override func setup() {
    self.backgroundColor = .white
    self.addSubViews(
      mapView,
      researchButton,
      addressContainerView,
      addressButton,
      storeCollectionView,
      currentLocationButton,
      tossButton,
      emptyCell
    )
  }
  
  override func bindConstraints() {
    self.mapView.snp.makeConstraints { (make) in
      make.edges.equalTo(0)
    }
    
    self.addressContainerView.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(25)
      make.right.equalToSuperview().offset(-25)
      make.top.equalTo(self.safeAreaLayoutGuide).offset(7)
      make.height.equalTo(56)
    }
    
    self.addressButton.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalTo(self.addressContainerView)
    }
    
    self.researchButton.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalTo(self.addressContainerView)
      make.height.equalTo(40)
    }
    
    self.storeCollectionView.snp.makeConstraints { (make) in
      make.left.right.equalToSuperview()
      make.bottom.equalTo(self.safeAreaLayoutGuide).offset(-24)
      make.height.equalTo(124)
    }
    
    self.tossButton.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-24)
      make.bottom.equalTo(self.storeCollectionView.snp.top).offset(-40)
    }
    
    self.currentLocationButton.snp.makeConstraints { (make) in
      make.right.equalTo(self.tossButton)
      make.bottom.equalTo(self.tossButton.snp.top).offset(-12)
    }
    
    self.emptyCell.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
      make.bottom.equalTo(self.safeAreaLayoutGuide).offset(-34)
      make.height.equalTo(104)
    }
  }
  
  func scrollToIndex(index: IndexPath) {
    self.storeCollectionView.scrollToItem(at: index, at: .left, animated: true)
  }
  
  func setSelectStore(indexPath: IndexPath, isSelected: Bool) {
    if let cell = self.storeCollectionView.cellForItem(at: indexPath) as? StoreCell {
      cell.setSelected(isSelected: isSelected)
    }
  }
  
  func isHiddenResearchButton(isHidden: Bool) {
    if isHidden {
      UIView.transition(
        with: self.researchButton,
        duration: 0.3,
        options: .curveEaseInOut
      ) {
        self.researchButton.transform = .identity
        self.researchButton.alpha = 0
      }
    } else {
      UIView.transition(
        with: self.researchButton,
        duration: 0.3,
        options: .curveEaseInOut
      ) {
        self.researchButton.transform = .init(translationX: 0, y: 56)
        self.researchButton.alpha = 1.0
      }
    }
  }
}
