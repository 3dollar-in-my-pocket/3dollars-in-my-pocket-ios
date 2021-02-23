import UIKit
import NMapsMap

class CategoryListMapCell: BaseTableViewCell {
  
  static let registerId = "\(CategoryListMapCell.self)"
  
  let mapView = NMFMapView()
  
  let currentLocationButton = UIButton().then {
    $0.setImage(UIImage.init(named: "ic_current_location"), for: .normal)
  }
  
  
  override func setup() {
    self.backgroundColor = .clear
    self.selectionStyle = .none
    self.addSubViews(mapView, currentLocationButton)
  }
  
  override func bindConstraints() {
    self.mapView.snp.makeConstraints { make in
      make.left.top.right.bottom.equalToSuperview()
      make.height.equalTo(396 * RatioUtils.heightRatio)
    }
    
    self.currentLocationButton.snp.makeConstraints { (make) in
      make.right.equalTo(mapView.snp.right).offset(-24)
      make.bottom.equalTo(mapView.snp.bottom).offset(-15)
      make.width.height.equalTo(48)
    }
  }
}
