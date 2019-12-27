import UIKit
import GoogleMaps

class HomeVC: BaseVC {
    
    private lazy var homeView = HomeView(frame: self.view.frame)
    
    
    static func instance() -> HomeVC {
        return HomeVC(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = homeView
        
        let camera = GMSCameraPosition.camera(withLatitude: 37.49838214755165, longitude: 127.02844798564912, zoom: 15)
        
        homeView.mapView.camera = camera
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 37.49838214755165, longitude: 127.02844798564912)
        marker.title = "닥고약기"
        marker.snippet = "무름표"
        marker.map = homeView.mapView
        initializeCategory()
    }
    
    override func bindViewModel() {
        homeView.mapButton.rx.tap.bind {
            AlertUtils.show(title: "Current position", message: "\(self.homeView.mapView.camera.target)")
        }.disposed(by: disposeBag)
    }
    
    private func initializeCategory() {
        homeView.categoryView.delegate = self
        homeView.categoryView.dataSource = self
        homeView.categoryView.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.registerId)
    }
}

extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.registerId, for: indexPath) as? CategoryCell else {
            return BaseCollectionViewCell()
        }
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}
