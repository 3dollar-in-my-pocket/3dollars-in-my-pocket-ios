import UIKit
import GoogleMaps

class HomeView: BaseView {
    
    let mapView = GMSMapView()
    
    let mapButton = UIButton().then {
        $0.setTitle("중앙 좌표 얻기", for: .normal)
        $0.backgroundColor = .white
        $0.setTitleColor(.black, for: .normal)
    }
    
    override func setup() {
        backgroundColor = .white
        addSubViews(mapView, mapButton)
    }
    
    override func bindConstraints() {
        mapView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        mapButton.snp.makeConstraints { (make) in
            make.top.equalTo(safeAreaLayoutGuide)
            make.right.equalToSuperview()
        }
    }
}
