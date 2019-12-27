import UIKit
import GoogleMaps

class HomeView: BaseView {
    
    let categoryView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        $0.backgroundColor = .white
        $0.collectionViewLayout = layout
    }
    
    let mapView = GMSMapView()
    
    let mapButton = UIButton().then {
        $0.setTitle("중앙 좌표 얻기", for: .normal)
        $0.backgroundColor = .gray
        $0.setTitleColor(.black, for: .normal)
    }
    
    override func setup() {
        backgroundColor = .white
        addSubViews(categoryView, mapView, mapButton)
    }
    
    override func bindConstraints() {
        
        categoryView.snp.makeConstraints { (make) in
            make.top.equalTo(safeAreaLayoutGuide)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        
        mapView.snp.makeConstraints { (make) in
            make.top.equalTo(categoryView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        mapButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
        }
    }
}
