import UIKit
import NMapsMap

class HomeView: BaseView {
  
  let mapView = NMFMapView()
  
  let addressContainerView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 16
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    $0.layer.shadowOpacity = 0.08
  }
  
  let addressButton = UIButton().then {
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
    $0.setImage(UIImage(named: "ic_arrow_bottom_black"), for: .normal)
    $0.semanticContentAttribute = .forceRightToLeft
    $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -8)
    $0.setTitleColor(.black, for: .normal)
  }
  
  let storeCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout()
  ).then {
    let layout = UICollectionViewFlowLayout()
    
    layout.scrollDirection = .horizontal
    layout.minimumInteritemSpacing = 12
    layout.itemSize = CGSize(
      width: 264,
      height: 104
    )
    $0.collectionViewLayout = layout
    $0.backgroundColor = .clear
    $0.showsHorizontalScrollIndicator = false
    $0.contentInset = UIEdgeInsets(
      top: 0,
      left: 24,
      bottom: 0,
      right: 24
    )
  }
  
  let currentLocationButton = UIButton().then {
    $0.setImage(UIImage(named: "ic_current_location"), for: .normal)
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    $0.layer.shadowOpacity = 0.15
  }
  
  let tossButton = UIButton().then {
    $0.setImage(UIImage(named: "ic_toss"), for: .normal)
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    $0.layer.shadowOpacity = 0.15
  }
  
  
  override func setup() {
    self.backgroundColor = .white
    self.addSubViews(
      mapView, addressContainerView, addressButton, storeCollectionView,
      currentLocationButton, tossButton
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
    
    self.storeCollectionView.snp.makeConstraints { (make) in
      make.left.right.equalToSuperview()
      make.bottom.equalTo(safeAreaLayoutGuide).offset(-24)
      make.height.equalTo(104)
    }
    
    self.tossButton.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-24)
      make.bottom.equalTo(self.storeCollectionView.snp.top).offset(-40)
    }
    
    self.currentLocationButton.snp.makeConstraints { (make) in
      make.right.equalTo(self.tossButton)
      make.bottom.equalTo(self.tossButton.snp.top).offset(-12)
    }
  }
  
  func scrollToIndex(index: IndexPath){
    self.storeCollectionView.scrollToItem(at: index, at: .left, animated: true)
  }
  
  func setSelectStore(indexPath: IndexPath, isSelected: Bool) {
    if let cell = self.storeCollectionView.cellForItem(at: indexPath) as? StoreCell {
      cell.setSelected(isSelected: isSelected)
    }
  }
}
