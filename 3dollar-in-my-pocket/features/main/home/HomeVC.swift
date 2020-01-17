import UIKit
import GoogleMaps

protocol HomeDelegate {
    func onTapCategory()
    
    func didDragMap()
    
    func endDragMap()
}

class HomeVC: BaseVC {
    
    var viewModel = HomeViewModel()
    var delegate: HomeDelegate?
    var locationManager = CLLocationManager()
    var isFirst = true
    var previousIndex = 0
    
    private lazy var homeView = HomeView(frame: self.view.frame)
    
    
    static func instance() -> HomeVC {
        return HomeVC(nibName: nil, bundle: nil)
    }
    
    
    deinit {
        locationManager.stopUpdatingLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = homeView
        
        setupShopCollectionView()
        setupGoogleMap()
        setupLocationManager()
    }
    
    override func bindViewModel() {
        viewModel.nearestStore
            .bind(to: homeView.shopCollectionView.rx.items(cellIdentifier: ShopCell.registerId, cellType: ShopCell.self)) { [weak self] row, storeCard, cell in
                if let vc = self {
                    if row == 0 && vc.isFirst {
                        cell.setSelected(isSelected: true)
                        vc.isFirst = false
                    }
                    cell.bind(storeCard: storeCard)
                }
        }.disposed(by: disposeBag)
        
        viewModel.location.subscribe(onNext: { [weak self] (latitude, longitude) in
            self?.getNearestStore(latitude: latitude, longitude: longitude)
        }).disposed(by: disposeBag)
        
        homeView.mapButton.rx.tap.bind { [weak self] in
            self?.locationManager.startUpdatingLocation()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation() // 화면 돌아올때마다 갱신해주면 좋을 것 같음!
    }
    
    private func setupShopCollectionView() {
        homeView.shopCollectionView.delegate = self
        homeView.shopCollectionView.register(ShopCell.self, forCellWithReuseIdentifier: ShopCell.registerId)
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func setupGoogleMap() {
        homeView.mapView.delegate = self
        homeView.mapView.isMyLocationEnabled = true
    }
    
    private func goToDetail() {
        self.navigationController?.pushViewController(DetailVC.instance(), animated: true)
    }
    
    private func getNearestStore(latitude: Double, longitude: Double) {
        StoreService.getStoreOrderByNearest(latitude: latitude, longitude: longitude) { [weak self] (response) in
            switch response.result {
            case .success(let storeCards):
                self?.viewModel.nearestStore.onNext(storeCards)
                self?.setMarker(storeCards: storeCards)
            case .failure(let error):
                AlertUtils.show(title: "error", message: error.localizedDescription)
            }
        }
    }
    
    private func setMarker(storeCards: [StoreCard]) {
        homeView.mapView.clear()
        for storeCard in storeCards {
            let marker = GMSMarker()
            
            marker.position = CLLocationCoordinate2D(latitude: storeCard.latitude, longitude: storeCard.longitude)
            marker.icon = markerWithSize(image: UIImage.init(named: "ic_marker_store_off")!, scaledToSize: CGSize.init(width: 16, height: 16))
            marker.map = homeView.mapView
            viewModel.markers.append(marker)
        }
    }
    
    private func markerWithSize(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}

extension HomeVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
        self.viewModel.location.onNext((location!.coordinate.latitude, location!.coordinate.longitude))
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        AlertUtils.show(title: "error locationManager", message: error.localizedDescription)
    }
}
