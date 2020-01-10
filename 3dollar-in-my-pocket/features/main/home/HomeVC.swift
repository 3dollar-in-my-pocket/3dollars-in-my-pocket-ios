import UIKit
import GoogleMaps

protocol HomeDelegate {
    func onTapCategory()
    
    func didDragMap()
    
    func endDragMap()
}

class HomeVC: BaseVC {
    
    var delegate: HomeDelegate?
    var locationManager = CLLocationManager()
    var isFirst = true
    var previousIndex = 0
    
    private lazy var homeView = HomeView(frame: self.view.frame)
    
    
    static func instance() -> HomeVC {
        return HomeVC(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = homeView
        
        homeView.shopCollectionView.delegate = self
        homeView.shopCollectionView.dataSource = self
        homeView.shopCollectionView.register(ShopCell.self, forCellWithReuseIdentifier: ShopCell.registerId)
        
        let camera = GMSCameraPosition.camera(withLatitude: 37.49838214755165, longitude: 127.02844798564912, zoom: 15)
        
        homeView.mapView.camera = camera
        homeView.mapView.delegate = self
        homeView.mapView.isMyLocationEnabled = true
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 37.49838214755165, longitude: 127.02844798564912)
        marker.title = "닥고약기"
        marker.snippet = "무름표"
        marker.map = homeView.mapView
        
        //Location Manager code to fetch current location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func bindViewModel() {
        homeView.mapButton.rx.tap.bind { [weak self] in
            self?.locationManager.requestLocation()
        }.disposed(by: disposeBag)
        
        homeView.bungeoppangTap.rx.event.bind { [weak self] (_) in
            self?.delegate?.onTapCategory()
        }.disposed(by: disposeBag)

        homeView.takoyakiTap.rx.event.bind { [weak self] (_) in
            self?.delegate?.onTapCategory()
        }.disposed(by: disposeBag)
        
        homeView.gyeranppangTap.rx.event.bind { [weak self] (_) in
            self?.delegate?.onTapCategory()
        }.disposed(by: disposeBag)

        homeView.hotteokTap.rx.event.bind { [weak self] (_) in
            self?.delegate?.onTapCategory()
        }.disposed(by: disposeBag)
    }
    
    private func goToDetail() {
        self.navigationController?.pushViewController(DetailVC.instance(), animated: true)
    }
}

extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShopCell.registerId, for: indexPath) as? ShopCell else {
            return BaseCollectionViewCell()
        }
        
        if indexPath.row == 0 && isFirst {
            cell.setSelected(isSelected: true)
            isFirst = false
        }
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 172, height: 172)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if previousIndex == indexPath.row { // 셀이 선택된 상태에서 한번 더 누르는 경우 상세화면으로 이동
            goToDetail()
        } else {
            collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
            if let cell = self.homeView.shopCollectionView.cellForItem(at: IndexPath(row: previousIndex, section: 0)) as? ShopCell {
                // 기존에 눌려있던 셀 deselect
                cell.setSelected(isSelected: false)
            }
            
            if let cell = self.homeView.shopCollectionView.cellForItem(at: indexPath) as? ShopCell {
                // 새로 누른 셀 select
                cell.setSelected(isSelected: true)
            }
            previousIndex  = indexPath.row
        }
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let pageWidth = CGFloat(172)
            let proportionalOffset = scrollView.contentOffset.x / pageWidth
            previousIndex = Int(round(proportionalOffset))
            let indexPath = IndexPath(row: previousIndex, section: 0)
            
            self.homeView.shopCollectionView.scrollToItem(at: indexPath, at: .left, animated: true)
            if let cell = self.homeView.shopCollectionView.cellForItem(at: indexPath) as? ShopCell {
                cell.setSelected(isSelected: true)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = CGFloat(172)
        let proportionalOffset = scrollView.contentOffset.x / pageWidth
        previousIndex = Int(round(proportionalOffset))
        let indexPath = IndexPath(row: previousIndex, section: 0)
        
        self.homeView.shopCollectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        if let cell = self.homeView.shopCollectionView.cellForItem(at: indexPath) as? ShopCell {
            cell.setSelected(isSelected: true)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let indexPath = IndexPath(row: previousIndex, section: 0)
        
        if let cell = self.homeView.shopCollectionView.cellForItem(at: indexPath) as? ShopCell {
            cell.setSelected(isSelected: false)
        }
    }
}

extension HomeVC: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture {
            self.delegate?.didDragMap()
        }
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        self.delegate?.endDragMap()
    }
}

extension HomeVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let camera = GMSCameraPosition.camera(withLatitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude, zoom: 15)
        
        self.homeView.mapView.animate(to: camera)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        AlertUtils.show(title: "error", message: error.localizedDescription)
    }
}
